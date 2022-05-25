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
private class Test_EventCustomLookupController{
    /**
    *  Purpose         :  Test class for EventCustomLookupController
    *               
    *  Created By      :  Dipesh Gupta
    *   
    *  Created Date    :  6/20/2020 
    *   
    *  Revision Log    :   v1.0  - Updated by - Neha Sharma - CR-20200716-14327 - 10/23/2020 - Search Events related to associated Membership Institution of Opportunity and ROI
                
    *                       
    *  Coverage        :    
    **/
    
    @testSetup static void setup() {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        test.startTest();
        
        // Account
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        List<Account> listOfAcc = [Select Id, Name From Account];
        System.assertEquals(1, listOfAcc.size());
        
        // Program
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        List<Program__c> listOfProgram = [Select Id, Name From Program__c];
        System.assertEquals(1, listOfProgram.size());

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        List<Membership__c> listOfMembership = [Select Id From Membership__c];
        System.assertEquals(1, listOfMembership.size());
        
        Account acc1 = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc1;
        Membership__c mem1 = new Membership__c(Account_Name__c = acc1.id, Program__c = prog.id);
        insert mem1;

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        Insert Project;
        
        List<Project__c> listOfProject = [Select Id, Name From Project__c];
        System.assertEquals(1, listOfProject.size());
        
        List<RecordType> rdType = [SELECT Id,Name FROM RecordType Where SobjectType = 'Opportunity_and_ROI__c' AND IsActive = true 
                                                AND DeveloperName = 'Research_Impact_Story'];
         List<RecordType> rdType2 = [SELECT Id,Name FROM RecordType Where SobjectType = 'Opportunity_and_ROI__c' AND IsActive = true 
                                                AND DeveloperName = 'Member_Success'];
        
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions; 
        
        List<SBQQ__Subscription__c> listOfSubscription = [Select Id From SBQQ__Subscription__c];
        System.assertEquals(2, listOfSubscription.size());

        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,
                                                                Stage__c = 'Honorary', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 2,Period_End_Date__c = Date.Today() + 5, 
                                                                Stage__c = 'Pending', Segment_Index__c = 100, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 3, Period_End_Date__c = Date.Today() + 5,
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Segment_Index__c = 13, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                     
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 5, Period_End_Date__c = Date.Today() + 8,
                                                                Stage__c = 'Pending', Segment_Index__c = 15, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                      
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
        
        List<Subscription_Period__c> listOfSubscriptionPer = [Select Id From Subscription_Period__c];
        System.assertEquals(4, listOfSubscriptionPer.size());
        
        //Create Opportunity and ROI record
        List<Opportunity_and_ROI__c> opportunityAndROI = new List<Opportunity_and_ROI__c>();
        
        Opportunity_and_ROI__c oppROI_1 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test1', Project__c = project.Id);
        Opportunity_and_ROI__c oppROI_2 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test2', Project__c = project.Id);
        Opportunity_and_ROI__c oppROI_3 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test3', Project__c = project.Id);
        Opportunity_and_ROI__c oppROI_4 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test4', Project__c = project.Id);
        Opportunity_and_ROI__c oppROI_5 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test5', Project__c = project.Id);
        
        opportunityAndROI.add(oppROI_1);
        opportunityAndROI.add(oppROI_2);
        opportunityAndROI.add(oppROI_3);
        opportunityAndROI.add(oppROI_4);
        opportunityAndROI.add(oppROI_5);
        
        Insert opportunityAndROI;
        
        List<Opportunity_and_ROI__c> listOfOppAndROI = [Select Id From Opportunity_and_ROI__c];
        System.assertEquals(5, listOfOppAndROI.size());
        
        //Insert event
        List<Event> events = new List<Event>();
        events.add(new event(subject = 'Will Auto-Populate', WhatId = listOfSubscriptionPeriod[0].Id, OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2), EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team'));
        
        events.add(new event(subject = 'Will Auto-Populate',WhatId = listOfSubscriptionPeriod[0].Id,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Chairmans Team', Visit_Location__c = 'Campus'));
        
        events.add(new event(subject = 'Will Auto-Populate',WhatId = listOfSubscriptionPeriod[0].Id,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team'));
        
        events.add(new event(subject = 'Will Auto-Populate',WhatId = listOfSubscriptionPeriod[0].Id,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team' ));
        
        events.add(new event(subject = 'Will Auto-Populate',WhatId = acc1.Id,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team'));
        
        events.add(new event(subject = 'Will Auto-Populate',WhatId = acc.Id,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team' ));
                                
        Insert events;
        
        List<event> listOfEvent = [Select Id From event];
        System.assertEquals(6, listOfEvent.size());
        
        test.stopTest();
    }
    
    @isTest static void test_EventCustomLookupControllerMethod(){
        Test.startTest();
        List<Event> evt = [Select id From Event];
        List<Opportunity_and_ROI__c> oppROI = [Select id,
                                               //Related_Onsite__c,
                                               Related_SL_Interaction__c,Related_Collaborative__c,Related_Benchmarking_Study__c From Opportunity_and_ROI__c];
        
        // before update
        //System.assert(oppROI[0].Related_Onsite__c == null);
        System.assert(oppROI[0].Related_SL_Interaction__c == null);
        System.assert(oppROI[0].Related_Collaborative__c == null);
        System.assert(oppROI[0].Related_Benchmarking_Study__c == null);
       
        EventCustomLookupController.updateOpportunityROI(String.valueOf(oppROI[0].Id), String.valueOf(evt[0].Id), String.valueOf(evt[1].Id), String.valueOf(evt[2].Id), String.valueOf(evt[3].Id));
        
        // after update
        List<Opportunity_and_ROI__c> oppROIUpdated = [Select id,
                                                      //Related_Onsite__c,
                                                      Related_SL_Interaction__c,Related_Collaborative__c,Related_Benchmarking_Study__c From Opportunity_and_ROI__c];
        //System.assert(oppROIUpdated[0].Related_Onsite__c != null);
        System.assert(oppROIUpdated[0].Related_SL_Interaction__c != null);
        System.assert(oppROIUpdated[0].Related_Collaborative__c != null);
        System.assert(oppROIUpdated[0].Related_Benchmarking_Study__c != null);
        
        EventCustomLookupController.RecordsData recordsData = new EventCustomLookupController.RecordsData();
        recordsData = EventCustomLookupController.fetchOppRecord(oppROI[0].Id);
        
        System.assert(recordsData != null);
        Test.stopTest();
    }
    
    @isTest static void test_EventCustomLookupControllerMethod_WithBlankValues(){
        Test.startTest();
        List<Opportunity_and_ROI__c> oppROI = [Select id,
                                               //Related_Onsite__c,
                                               Related_SL_Interaction__c,Related_Collaborative__c,Related_Benchmarking_Study__c From Opportunity_and_ROI__c];
        
        // before update
        //System.assert(oppROI[0].Related_Onsite__c == null);
        System.assert(oppROI[0].Related_SL_Interaction__c == null);
        System.assert(oppROI[0].Related_Collaborative__c == null);
        System.assert(oppROI[0].Related_Benchmarking_Study__c == null);
        EventCustomLookupController.updateOpportunityROI(String.valueOf(oppROI[0].Id),null,null,null,null);
        
        // after update
        List<Opportunity_and_ROI__c> oppROIUpdated = [Select id,
                                                      //Related_Onsite__c,
                                                      Related_SL_Interaction__c,Related_Collaborative__c,Related_Benchmarking_Study__c From Opportunity_and_ROI__c];
        //System.assert(oppROIUpdated[0].Related_Onsite__c == null);
        System.assert(oppROIUpdated[0].Related_SL_Interaction__c == null);
        System.assert(oppROIUpdated[0].Related_Collaborative__c == null);
        System.assert(oppROIUpdated[0].Related_Benchmarking_Study__c == null);
        
        //EventCustomLookupController.fetchOppRecord(oppROI[0].Id);
        //EventCustomLookupController.fetchRecords(null,null,null);
        Test.stopTest();
    }
    
    @isTest static void test_EventCustomLookupControllerMethod_FetchOppRecord(){
        Test.startTest();
        List<Opportunity_and_ROI__c> oppROI = [Select id From Opportunity_and_ROI__c];
        EventCustomLookupController.fetchOppRecord(oppROI[0].Id);
        Test.stopTest();
    }
    
    @isTest static void test_EventCustomLookupControllerMethod_FetchRecord(){
        Test.startTest();
        try
        {
           List<Opportunity_and_ROI__c> oppROI = [Select id From Opportunity_and_ROI__c];
           EventCustomLookupController.fetchRecords('Event', 'Subject', 'Test', oppROI[0].Id);
        }
        catch(exception e)
        {
            System.debug('msg' + e.getMessage() + ' --- '+e.getLineNumber());
        }     

        Test.stopTest();
    }
    //Created by - Neha Sharma - CR-20200716-14327 - 10/23/2020 - Search Events related to associated Membership Institution of Opportunity and ROI
                
    @isTest static void test_InstitutionRelatedEvent_FetchRecord(){
        
        Util.byPassAllTriggers = true;
        
        //get Membership
        List<Membership__c> memberships = [Select Id,Account_Name__c From Membership__c WHERE Account_Name__c != null];
                
        event evt = new event(subject = 'Call',WhatId = memberships[0].Account_Name__c,OwnerId = Userinfo.getUserId(),
                                StartDateTime = system.today().addDays(2),EndDateTime = system.today().addDays(2), type = 'Research',
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairmans Team', RecordTypeId = constants.RECORD_TYPE_ID_MEMBER_SUCCESS);
                                
        Insert evt;
        
        //get Record Type
        List<RecordType> rdType = [SELECT Id,Name FROM RecordType Where SobjectType = 'Opportunity_and_ROI__c' AND IsActive = true 
                                                AND DeveloperName = 'Research_Impact_Story'];
        //get Project
        List<Project__c> listOfProject = [Select Id, Name From Project__c];
        
        //Add Opportunity and ROI
        Opportunity_and_ROI__c oppROI_1 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test1', Project__c = listOfProject[0].Id, Membership__c = memberships[0].Id);
        Opportunity_and_ROI__c oppROI_2 = new Opportunity_and_ROI__c(RecordTypeId = rdType[0].Id, Name = 'Test2', Project__c = listOfProject[0].Id, Membership__c = memberships[1].Id);
        
        List<Opportunity_and_ROI__c> opportunityAndROI = new List<Opportunity_and_ROI__c>();//{oppROI_1,oppROI_2}
        opportunityAndROI.add(oppROI_1);
        opportunityAndROI.add(oppROI_2);
        Insert opportunityAndROI;
        
        Util.byPassAllTriggers = false;
        
        Test.startTest();

        List<EventCustomLookupController.RecordsData> recordsWrap = EventCustomLookupController.fetchRecords('Event', 'Subject', 'Call', opportunityAndROI[0].Id);
        System.assert(recordsWrap.size()>0);
        Test.stopTest();
    }
}