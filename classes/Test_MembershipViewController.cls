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
@isTest
private class Test_MembershipViewController {
    
    
    static testMethod void testMemViewController_StandardUser() {
        Util.IsTest(true);
        Account acct = TestUtilities.CreateNewAccount(true);
        Program__c prog = TestUtilities.CreateNewProgram(true);
        Membership__c mem = TestUtilities.CreateNewMembership(acct.Id, prog.Id, true);
        PageReference pageRef = Page.MembershipView;
        Test.setCurrentPageReference(pageRef);
        // standard controller for membership
        ApexPages.StandardController stdCon = new ApexPages.standardController(mem);
        //pageRef.getParameters().put('id', myContact.Id);
        // create an instance of the controller
        MembershipViewController controller = new MembershipViewController(stdCon);
       /* system.assertEquals(true, controller.ReadAccess_MemKeyContact);
        system.assertEquals(true, controller.ReadAccess_MemInteraction);
        system.assertEquals(true, controller.ReadAccess_SyndicatedResearch);
        system.assertEquals(true, controller.ReadAccess_MeetingUtils);
        system.assertEquals(true, controller.ReadAccess_TeleconfUtils);
        system.assertEquals(true, controller.ReadAccess_OtherUtils);
        system.assertEquals(true, controller.ReadAccess_Projects);*/
    }
    
    static testMethod void testMemViewController_ChatterOnlyUser() {
        Util.IsTest(true);
        Account acct = TestUtilities.CreateNewAccount(true);
        system.assert(acct != null);
        
        Program__c prog = TestUtilities.CreateNewProgram(true);
        system.assert(prog != null);
        
        Membership__c mem = TestUtilities.CreateNewMembership(acct.Id, prog.Id, true);
		
        system.assert(mem != null);
        
        //Updated by Colin McGloin - CR-10337
        //Query through  profile to get Id Of Profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = :Label.DeliveryAppSubscriptionUser];
        
        //User Insert
        User DeliveryAppSubUser = TestUtilities.CreateNewUser(profile, True);

        system.runAs(DeliveryAppSubUser) {
            PageReference pageRef = Page.MembershipView;
            Test.setCurrentPageReference(pageRef);
            // standard controller for membership
            ApexPages.StandardController stdCon = new ApexPages.standardController(mem);
            //pageRef.getParameters().put('id', myContact.Id);
            // create an instance of the controller
            MembershipViewController controller = new MembershipViewController(stdCon);
            //system.assertEquals(true, controller.ReadAccess_MemInteraction);
        }
    }
    
    // add tasks and events to an Opportunity related to a membership
    // verify the tasks and events are displayed on the MembershipView page in the related list
    static testMethod void testMemViewController_getRecords() {
        Util.IsTest(true);
        Util.byPassAlltriggers = true;
            
        Account acct = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(acct, true);
        Program__c prog = TestUtilities.CreateNewProgram(true);
        Membership__c mem = TestUtilities.CreateNewMembership(acct.Id, prog.Id, true);
        Opportunity opp = TestUtilities.CreateNewOpportunity(acct.Id, false);
        opp.Program__c = prog.Id;
        opp.Membership__c = mem.Id;
        insert opp;
        
        //create membership key contact
        Membership_Key_Contact__c memKeyContact = new Membership_Key_Contact__c(Contact__c = con.Id,
                                                                     Membership__c = mem.Id,
                                                                     Pubs__c = true);
        insert memKeyContact;
        
        //Start test from here
        test.startTest();
        
        Event event_memKeyContact_Future = TestUtilities.CreateNewEvent(false);
        event_memKeyContact_Future.WhatId = null;
        event_memKeyContact_Future.WhoId = con.Id;
        event_memKeyContact_Future.StartDateTime = system.today().addDays(2);
        
        Event event_memKeyContact_Past = event_memKeyContact_Future.clone();
        event_memKeyContact_Past.StartDateTime = system.today().addDays(-2);
        
        Event event_Future = TestUtilities.CreateNewEvent(false);
        event_Future.WhatId = opp.Id;
        event_Future.StartDateTime = system.today().addDays(2);
        Event event_Historical = TestUtilities.CreateNewEvent(false);
        event_Historical.WhatId = opp.Id;
        event_Historical.StartDateTime = system.today().addDays(-2);
        Event event_Historical_OnMembership = TestUtilities.CreateNewEvent(false);
        event_Historical_OnMembership.WhatId = mem.Id; // assign the related To = Membership
        event_Historical_OnMembership.StartDateTime = system.today().addDays(-2);
        List<Event> evtList = new List<Event> { event_Future, event_Historical, event_Historical_OnMembership, event_memKeyContact_Future, event_memKeyContact_Past };
        insert evtList;

        // create a task
        Task tsk = new Task();
        tsk.WhoId = con.Id;
        tsk.Status = 'Not Started';
        tsk.WhatId = opp.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = system.today().addDays(2);
        insert tsk;

        //Loading the VF page
        PageReference pageRef = Page.MembershipView;
        Test.setCurrentPageReference(pageRef);
            
        // standard controller for membership
        ApexPages.StandardController stdCon = new ApexPages.standardController(mem);

        //pageRef.getParameters().put('id', myContact.Id);
        // create an instance of the controller
        MembershipViewController controller = new MembershipViewController(stdCon);

        //Stop test here
        test.stopTest();

        //Pagereference
        PageReference pg = new PageReference('/' + mem.Id + '?nooverride=1');
        
        //Asserting for the results
        system.assertEquals(3, controller.historicalEventOrTaskList.size());
        system.assertEquals(3, controller.openEventOrTaskList.size());
        //system.assertEquals(0, controller.NumMemberInteractions);
    }
}