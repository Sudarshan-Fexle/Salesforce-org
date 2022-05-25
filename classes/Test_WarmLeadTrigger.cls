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
private class Test_WarmLeadTrigger {

/**
 *  Purpose         :   Test class for warm Lead Trigger
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   02/22/2014
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - 08/06/2014 - CR-20140610-5761
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/14/2014 - CR-20140623-5887
 *                      V_1.3 - Modified By - Abhinav Sharma - 11/25/2014 - CR-20141029-7923
 * 			V_1.4 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20150908-9227 
 *			V_1.5 - Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
 **/ 
    //Modified By - Abhinav Sharma - 10/20/2015 - CR-20150908-9227 
    //CR-20140121-4302
    //Modified By - Abhinav Sharma - 08/06/2014 - CR-20140610-5761
    static testMethod void testUpdateLeadInfoOnContact() {
        
        //Create Test data
        //Flag for testing mode on triggers
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        Account account = new Account(Name='Temp', Account_Formal_Name__c = 'Test', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
        insert account;
        
        Program__c program = new Program__c( Name = 'Progname', Program_Acronym__c = 'TEST');
        insert program;
        
        //List to hold the contact records
        List<Contact> contacts = new List<Contact>();
        
        //Contact record
        Contact contact_1 = new Contact(LastName = 'Test1', AccountId = account.Id,Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        Contact contact_2 = new Contact(LastName = 'Test2', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        Contact contact_3 = new Contact(LastName = 'Test3', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        
        //Adding instances into the list and then make a try to insert it
        contacts.add(contact_1);
        contacts.add(contact_2);
        contacts.add(contact_3);
        insert contacts;
        
        //Creating custom setting data
        List<Reporting_Lead_Channel_Setting__c> listReportingChannelSettings = new List<Reporting_Lead_Channel_Setting__c>();
        
        //Reporting_Lead_Channel_Setting__c instance
        Reporting_Lead_Channel_Setting__c rLCS_1 = new Reporting_Lead_Channel_Setting__c(Name = '1', Lead_Event__c = 'CG - Research',
                                                                                        	Lead_origin__c = 'Advisory.com', Reporting_Lead_Channel_Value__c = 'Advisory.com');
        //Reporting_Lead_Channel_Setting__c instance
        Reporting_Lead_Channel_Setting__c rLCS_2 = new Reporting_Lead_Channel_Setting__c(Name = '2', Lead_Event__c = 'Breakout',
                                                                                        	Lead_origin__c = 'Eloqua-Internal Event', Reporting_Lead_Channel_Value__c = 'Breakout');
        
        //Adding records into the list
        listReportingChannelSettings.add(rLCS_1);
        listReportingChannelSettings.add(rLCS_2);
        insert listReportingChannelSettings;
        
        //List to hold the Warm Lead records
        List<Warm_Lead__c> listWarmLists = new List<Warm_Lead__c>();
        
        Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Direct to Visit', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Direct to Visit', Lead_Date__c = system.today(), 
                                                    Grade__c = '1', Contact__c = contacts[0].Id, Status__c = 'Test1');
        
        Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test2', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Strategy Retreat', Lead_Date__c = system.today().addDays(-1), 
                                                    Grade__c = '1', Contact__c = contacts[0].Id, Status__c = 'Test2');
                                                    
        Warm_Lead__c warmLead_3 = new Warm_Lead__c(Name = 'Test3', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Webinar', Lead_Date__c = system.today().addDays(-2), 
                                                    Grade__c = '1', Contact__c = contacts[0].Id, Status__c = 'Test3');
                                                    
        Warm_Lead__c warmLead_4 = new Warm_Lead__c(Name = 'Test4', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Speaking Engagement', Lead_Date__c = system.today(), 
                                                    Grade__c = '1', Contact__c = contacts[1].Id, Status__c = 'Test4');
        
        Warm_Lead__c warmLead_5 = new Warm_Lead__c(Name = 'Test5', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Prospect Meeting', Lead_Date__c = system.today().addDays(-1), 
                                                    Grade__c = '1', Contact__c = contacts[1].Id, Status__c = 'Test5');
        
        Warm_Lead__c warmLead_6 = new Warm_Lead__c(Name = 'Test6', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Breakout', Lead_Date__c = system.today().addDays(-2), 
                                                    Grade__c = '1', Contact__c = contacts[1].Id, 
                                                   	Lead_origin__c = 'Eloqua-Internal Event', Status__c = 'Test6');
                                                    
        Warm_Lead__c warmLead_7 = new Warm_Lead__c(Name = 'Test7', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'CG - Research', Lead_Date__c = system.today(), 
                                                    Grade__c = '1', Contact__c = contacts[2].Id, 
                                                    Lead_origin__c = 'Advisory.com', Status__c = 'Test7');
        
        Warm_Lead__c warmLead_8 = new Warm_Lead__c(Name = 'Test8', Account__c = account.Id, Primary_Program__c = program.Id,
                                                    Lead_Channel__c = 'Request Access', Lead_Date__c = system.today().addDays(-1), 
                                                    Grade__c = '1', Contact__c = contacts[2].Id, Status__c = 'Test8');
                                                    
        //Adding instances into the list and then make a try to insert it
        listWarmLists.add(warmLead_1); listWarmLists.add(warmLead_2); listWarmLists.add(warmLead_3);
        listWarmLists.add(warmLead_4); listWarmLists.add(warmLead_5); listWarmLists.add(warmLead_6);
        listWarmLists.add(warmLead_7); listWarmLists.add(warmLead_8);
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Insert Warm Leads
        insert listWarmLists;
        
        //Querying contact details
        contacts = [Select ID, Most_Recent_Lead_Date__c, Most_Recent_Lead_Event__c FROM Contact ORDER BY LastName ASC];
        
        //Assert for the results
        System.assertEquals(8, listWarmLists.size());
        System.assertEquals(listWarmLists[0].Lead_Date__c, contacts[0].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[0].Lead_Channel__c, contacts[0].Most_Recent_Lead_Event__c);
        System.assertEquals(listWarmLists[4].Lead_Date__c, contacts[1].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[4].Lead_Channel__c, contacts[1].Most_Recent_Lead_Event__c);
        System.assertEquals(listWarmLists[6].Lead_Date__c, contacts[2].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[6].Lead_Channel__c, contacts[2].Most_Recent_Lead_Event__c);
        
        listWarmLists = [SELECT Id, Lead_Date__c, Lead_Channel__c, Reporting_Lead_Channel__c FROM Warm_Lead__c
                        	ORDER BY Status__c ASC];
        System.assertEquals(8, listWarmLists.size());
        System.assertEquals(null, listWarmLists[0].Reporting_Lead_Channel__c);
        System.assertEquals(null, listWarmLists[1].Reporting_Lead_Channel__c);
        System.assertEquals(null, listWarmLists[2].Reporting_Lead_Channel__c);
        System.assertEquals(null, listWarmLists[3].Reporting_Lead_Channel__c);
        System.assertEquals(null, listWarmLists[4].Reporting_Lead_Channel__c);
        System.assertEquals('Breakout', listWarmLists[5].Reporting_Lead_Channel__c);
        System.assertEquals('Advisory.com', listWarmLists[6].Reporting_Lead_Channel__c);
        System.assertEquals(null, listWarmLists[7].Reporting_Lead_Channel__c);
        
        //Update Lead Data
        listWarmLists[0].Lead_Channel__c = 'CG - Tool';
        listWarmLists[4].Lead_Date__c = System.today().addDays(-2);
        listWarmLists[6].Lead_Channel__c = 'CG - Benchmarks';
        update listWarmLists;
        
        //Querying contact details
        contacts = [Select ID, Most_Recent_Lead_Date__c, Most_Recent_Lead_Event__c FROM Contact ORDER BY LastName ASC];
        
        //Assert for the results
        System.assertEquals(8, listWarmLists.size());
        System.assertEquals(listWarmLists[1].Lead_Date__c, contacts[0].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[1].Lead_Channel__c, contacts[0].Most_Recent_Lead_Event__c);
        System.assertEquals(listWarmLists[4].Lead_Date__c, contacts[1].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[4].Lead_Channel__c, contacts[1].Most_Recent_Lead_Event__c);
        System.assertEquals(listWarmLists[6].Lead_Date__c, contacts[2].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[6].Lead_Channel__c, contacts[2].Most_Recent_Lead_Event__c);
        
        //List to hold the warm leads
        List<Warm_Lead__c> warmLeadsForDelete = new List<Warm_Lead__c>();
        
        //Populating list with records
        warmLeadsForDelete.add(listWarmLists[1]);
        for(Integer j=3; j<=7; j++) {
            warmLeadsForDelete.add(listWarmLists[j]);
        }
        
        //Asserting for list size
        System.assertEquals(6, warmLeadsForDelete.size());
        
        //Performing deletion over the warm leads list'
        delete warmLeadsForDelete;
        
        //Querying contact details
        contacts = [Select ID, Most_Recent_Lead_Date__c, Most_Recent_Lead_Event__c FROM Contact ORDER BY LastName ASC];
        
        //Assert for the results
        System.assertEquals(listWarmLists[2].Lead_Date__c, contacts[0].Most_Recent_Lead_Date__c);
        System.assertEquals(listWarmLists[2].Lead_Channel__c, contacts[0].Most_Recent_Lead_Event__c);
        System.assertEquals(null, contacts[1].Most_Recent_Lead_Date__c);
        System.assertEquals(null, contacts[1].Most_Recent_Lead_Event__c);
        System.assertEquals(null, contacts[2].Most_Recent_Lead_Date__c);
        System.assertEquals(null, contacts[2].Most_Recent_Lead_Event__c);
        
        //Stop Test here
        Test.stopTest();
        
        //Populating list with records
        warmLeadsForDelete = new List<Warm_Lead__c>();
        warmLeadsForDelete.add(listWarmLists[0]);
        warmLeadsForDelete.add(listWarmLists[2]);
        delete warmLeadsForDelete;
        
        //Querying contact details
        contacts = [Select ID, Most_Recent_Lead_Date__c, Most_Recent_Lead_Event__c FROM Contact ORDER BY LastName ASC];
        
        //Assert for the results
        System.assertEquals(null, contacts[0].Most_Recent_Lead_Date__c);
        System.assertEquals(null, contacts[0].Most_Recent_Lead_Event__c);
        System.assertEquals(null, contacts[1].Most_Recent_Lead_Date__c);
        System.assertEquals(null, contacts[1].Most_Recent_Lead_Event__c);
        System.assertEquals(null, contacts[2].Most_Recent_Lead_Date__c);
        System.assertEquals(null, contacts[2].Most_Recent_Lead_Event__c);
    }
    
    //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
    static testMethod void testPopulateInitialVisitDate() {
        
        //Create Test data
        //Flag for testing mode on triggers
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            Account account = new Account(Name='Temp', Account_Formal_Name__c = 'Test', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
            insert account;
            
            Program__c program = new Program__c( Name = 'Progname', Program_Acronym__c = 'TEST');
            insert program;
        
            //List to hold the contact records
            List<Contact> contacts = new List<Contact>();
            
            //Contact record
            Contact contact_1 = new Contact(LastName = 'Test1', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
            Contact contact_2 = new Contact(LastName = 'Test2', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        
            //Adding instances into the list and then make a try to insert it
            contacts.add(contact_1);
            contacts.add(contact_2);
            insert contacts;
            
            //List to hold the Warm Lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Direct to Visit', Account__c = account.Id, Primary_Program__c = program.Id,
                                                        Lead_Channel__c = 'Direct to Visit', Lead_Date__c = system.today(), 
                                                        Grade__c = '1', Contact__c = contacts[0].Id);
            warmLeads.add(warmLead_1);
            insert warmLeads;
            
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today(), RecordTypeId = recordTypes[0], Sales_Pursuit_Products__c = 'APS');
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],Sales_Pursuit_Products__c = 'APS');
                                                         
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            insert opportunities;
            
            //List to hold the events
            List<Event> events = new List<Event>();
            
            //Event
            Event ev_1 = new Event(WhatId = opportunities[0].Id, StartDateTime = System.today(), ActivityDateTime = System.today(), ActivityDate = System.today(),
                                   Cancelled_Did_Not_Occur__c = false, EndDateTime = System.today().addDays(1),Event_Type__c = 'In Person Visit',
                                   Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
            
            //Event
            Event ev_2 = new Event(WhatId = opportunities[1].Id, StartDateTime = System.today().addDays(-2), ActivityDateTime = System.today().addDays(-2), ActivityDate = System.today().addDays(-2),
                                   Cancelled_Did_Not_Occur__c = false, EndDateTime = System.today().addDays(1),Event_Type__c = 'In Person Visit',
                                   Event_Purpose__c = 'Initial' , Visit_Location__c = 'Campus');
            
            //Adding records in the list
            events.add(ev_1);
            events.add(ev_2);
            
            //Enabling triggers again
            Util.byPassAllTriggers = false;
            
            //Insert events
            insert events;
            
            //Asserting for the results
            opportunities = [SELECT ID, Initial_Visit_Date__c FROM Opportunity ORDER BY Name ASC LIMIT 3];
            System.assertEquals(System.today(),opportunities[0].Initial_Visit_Date__c);
            System.assertEquals(System.today().addDays(-2),opportunities[1].Initial_Visit_Date__c);
                
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[1].Id);
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            
            //Test will start from here
            Test.startTest();
            
            //Enabling trigger again
            Util.byPassAllTriggers = false;
        
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_Visit_Date__c, Name FROM Warm_Lead__c ORDER BY Name ASC LIMIT 4];
            System.assertEquals(System.today().addDays(-2), warmLeads[0].Initial_Visit_Date__c);
            
            //update warm lead
            warmLeads[0].Initial_Visit_Date__c = null;
            update warmLeads;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_Visit_Date__c, Name FROM Warm_Lead__c ORDER BY Name ASC LIMIT 4];
            System.assertEquals(System.today().addDays(-2), warmLeads[0].Initial_Visit_Date__c);
            
            //Stop Test here
            Test.stopTest();
        }
    }

    static testMethod void test_PrepopulateAccountOnWarmLead()
    {
        Account account = new Account(Name='Temp', Account_Formal_Name__c = 'Test', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
        Util.byPassAllTriggers = true;
        insert account;
        Util.byPassAllTriggers = false;
        
        Program__c program = new Program__c( Name = 'Progname', Program_Acronym__c = 'TEST');
        Util.byPassAllTriggers = true;
        insert program;
        Util.byPassAllTriggers = false; 
        
        //List to hold the contact records
        List<Contact> contacts = new List<Contact>();
        
        //Contact record
        Contact contact_1 = new Contact(LastName = 'Test1', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        Contact contact_2 = new Contact(LastName = 'Test2', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        
        //Adding instances into the list and then make a try to insert it
        contacts.add(contact_1);
        contacts.add(contact_2);
        Util.byPassAllTriggers = true;
        insert contacts;
        Util.byPassAllTriggers = false;
        
        //Event
        Event event= new Event(WhatId = account.Id, StartDateTime = System.today(), ActivityDateTime = System.today(), ActivityDate = System.today(),
                               Cancelled_Did_Not_Occur__c = false, EndDateTime = System.today().addDays(1),Event_Type__c = 'In Person Visit',
                               Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
        insert event;
        
        //List to hold the Warm Lead records
        List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
        
        Warm_Lead__c warmLead = new Warm_Lead__c(Name = 'Direct to Visit', Primary_Program__c = program.Id,
                                                 Lead_Channel__c = 'Direct to Visit', Lead_Date__c = system.today(), 
                                                 Grade__c = '1', Contact__c = contacts[0].Id, Event_Id__c = event.Id);
        warmLeads.add(warmLead);
        insert warmLeads;
        
    }
}