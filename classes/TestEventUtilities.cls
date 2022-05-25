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
 // V1.1   Modified By - Rajeev Jain - 18/02/2020 - CR-20190929-13381 -  Remove zzzRole(Role__c) field 
@isTest
private class TestEventUtilities {
    
    //08/07/2019 - Victor Hanson - added to test populateNoContact method
    static testMethod void testPopulateNoContact() {
        
        //bypass all triggers
        Util.bypassAllTriggers = true;
        
        //create Institutions
        Account acct1 = TestUtilities.CreateNewAccount(false);
        Account acct2 = TestUtilities.CreateNewAccount(false);
        List<Account> accts = new List<Account> { acct1, acct2 };
        insert accts;
            
        //create a Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //create Memberships
        Membership__c mem1 = TestUtilities.CreateNewMembership(acct1.Id, prog.Id, false);
        Membership__c mem2 = TestUtilities.CreateNewMembership(acct2.Id, prog.Id, false);
        List<Membership__c> mems = new List<Membership__c> { mem1, mem2 };
        insert mems;
        
        //create Projects
        Project__c proj1 = TestUtilities.createProject(false);
        proj1.Institution__c = acct1.Id;
        Project__c proj2 = TestUtilities.createProject(false);
        proj2.Institution__c = acct2.Id;
        List<Project__c> projs = new List<Project__c> { proj1, proj2 };
        insert projs;
        
        //re-activate triggers
        Util.bypassAllTriggers = false;
        
        //create events for Membership and Project
        Event evtMem1 = TestUtilities.CreateNewEvent(false);
        evtMem1.WhatId = mem1.Id;
        Event evtMem2 = TestUtilities.CreateNewEvent(false);
        evtMem2.WhatId = mem2.Id;
        Event evtProj1 = TestUtilities.CreateNewEvent(false);
        evtProj1.WhatId = proj1.Id;
        Event evtProj2 = TestUtilities.CreateNewEvent(false);
        evtProj2.WhatId = proj2.Id;
        List<Event> evts = new List<Event> { evtMem1, evtMem2, evtProj1, evtProj2 };
        
        //insert event within start/stop test so @future method can execute
        test.startTest();
            
        insert evts;
            
        test.stopTest();
        
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :accts];
        
        //contact assertions
        system.assertEquals(2, contacts.size(), 'there should be 2 contacts.  One for each institution');
        
        for (Contact c : contacts) {
            system.assertEquals(c.Name, Constants.NO_CONTACT_NAME);
        }
        
        evts = [SELECT Id, WhatId, WhoId, AccountId FROM Event WHERE Id IN :evts];
        
        for (Event e : evts) {
            
            system.assertNotEquals(null, e.WhatId);
            //verify the WhoId is not null
            system.assertNotEquals(null, e.WhoId);
            
            //verify each event is associated to the correct accountId.  This verifies the contact is assigned correctly
            if (e.Id == evtMem1.Id)
                system.assertEquals(acct1.Id, e.AccountId);
            if (e.Id == evtMem2.Id)
                system.assertEquals(acct2.Id, e.AccountId);
            if (e.Id == evtProj1.Id)
                system.assertEquals(acct1.Id, e.AccountId);
            if (e.Id == evtProj2.Id)
                system.assertEquals(acct2.Id, e.AccountId);
        }
    }
    
    //06/23/2019 - Victor Hanson - added to test PopulateAllInstRoles method
    static testMethod void testPopulateAllInstRoles() {
        
        //create contact record
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //create team roles
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'EAB: VP of Advancement', Active__c = true, Institution_Role_External__c = true));
        teamRoles.add(new Team_Role__c(Name = 'EAB: Director of Facilities', Active__c = true, Institution_Role_External__c = true));
        
        //Insert teamRoles
        insert teamRoles;
        
        //create institute role
        Institution_Roles__c  instRole = new Institution_Roles__c(Assignment_Role__c=teamRoles[0].Id, Contact__c = contact.Id, Institution__c = contact.AccountId);
        insert instRole;
        
        //create event
        Event e = TestUtilities.CreateNewEvent(false);
        e.WhoId = contact.Id;
        
        //insert event within start/stop test so @future method can execute
        test.startTest();
            
            insert e;
            
        test.stopTest();
        
        e = [SELECT Id, All_Institution_Roles__c FROM Event WHERE Id = :e.Id];
        system.assertEquals('EAB: VP of Advancement', e.All_Institution_Roles__c);
    }
    
    static testMethod void testIsPrewire() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Prewire';
        insert evt;
        
        boolean isPrewire = EventUtilities.IsPrewire(evt);
        // assert that it returns true
        system.assertEquals(true, isPrewire);
    }
    
    static testMethod void testIsNotPrewire() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Call';
        insert evt;
        
        boolean isPrewire = EventUtilities.IsPrewire(evt);
        // assert that it returns false
        system.assertEquals(false, isPrewire);
    }
    
    //Test class for the method updateContactProtocoledField
    static testMethod void testupdateContactProtocoledField() {
        
        Util.IsTest(true);
        
        //Get Record Type
        Id EventSalesRecordType = Util.RecordTypeId('Event', 'Sales');
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);
        
        Event evt = TestUtilities.CreateNewEvent(false);
        evt.RecordTypeId = EventSalesRecordType;
        evt.whatId = testAccount.Id;
        evt.whoId = con.Id;
        evt.Cancelled_Did_Not_Occur__c = false;
		datetime datestart = Datetime.newInstance(2015, 20 , 12, 00, 00, 00);
		datetime dateend = Datetime.newInstance(2015, 20 , 12, 01, 00, 00);
		evt.EndDateTime = dateend;
		evt.StartDateTime = datestart ; 
		evt.DurationInMinutes = 60;
        
        insert evt;
        
    }
}