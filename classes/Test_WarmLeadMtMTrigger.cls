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
private class Test_WarmLeadMtMTrigger {
/**
 *  Purpose         :   This class is test class for Trigger on WarmLeadMtM.
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   06/13/2013
 *
 *  Current Version :   v1.0
 *
 *  Revision Logs   :   v1.0 - Created - CR-20121130-1808
 *                      v1.1 - (SUNJ 12/19/13) - CR-20130118-2218  
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/24/2015 - CR-20140613-5790          
 *
 *  Coverage        :   100%
 *
 **/
    static testMethod void testValidateWarmLeadMtMData() {
    
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
         
        // get one record type name
        List<Id> recordTypes = new List<Id>();
        recordTypes.add(Util.RecordTypeId('Warm_Lead__c',Constants.RECORD_TYPE_NAME_WARM_LEAD_STANDARD));
        recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
        
        //assert statement
        System.assertEquals(2, recordTypes.size());
        
        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Create Opportunity record
        Opportunity opportunity = new Opportunity(Name = 'Opportunity Test', StageName = 'ATL', Amount = 4.00,
                                                     CloseDate = Date.today(), RecordTypeId = recordTypes[1]);
        
        //insert Opprotunity
        insert opportunity;
        
        //Create Opportunity record
        Opportunity opportunity1 = new Opportunity(Name = 'Opportunity Test1', StageName = 'ATL', Amount = 4.00,
                                                     CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[1]);
        
        //insert Opprotunity
        insert opportunity1;
        
        //Create Warm Lead record 
        Warm_Lead__c warmLead = new Warm_Lead__c(Name = 'Test Warm Lead', Grade__c = '1', Lead_Date__c = Date.today(),
                                                    Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                    Marketer_Assignment__c = usr.Id, Status__c = 'Pending', Primary_Program__c = prog.Id);
                                                    
        //test start here
        Test.startTest();
        
        //insert Warm Lead here
        insert warmLead;
        
        //Create WarmLeadMtM record
        Warm_Lead_MtM__c warmLeadMtM = new Warm_Lead_MtM__c(Warm_Lead__c = warmLead.Id, Opportunity__c = opportunity.Id);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //insert WarmLeadMtM
        insert warmLeadMtM;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Create WarmLeadMtM record
        Warm_Lead_MtM__c warmLeadMtM2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLead.Id, Opportunity__c = opportunity.Id);
        
        try {
            
            //Enabling triggers again
            Util.byPassAllTriggers = false;
            
            //insert WarmLeadMtM
            insert warmLeadMtM2;
            
            //assert statement
            System.assert(false);
            
        } catch (Exception e) {
            
            //assert statement
            System.assert(true);
        }                       
        
        //insert WarmLeadMtM record
        warmLeadMtM2.Opportunity__c = opportunity1.Id;
        insert warmLeadMtM2;
        
        //Query result for WarmLeadMtM
        warmLeadMtM = [SELECT Warm_Lead__c, Opportunity__c FROM Warm_Lead_MtM__c WHERE Id =: warmLeadMtM.Id];
        
        try{
            
            //update WarmLeadMtM record
            warmLeadMtM.Opportunity__c = opportunity1.Id;
            update warmLeadMtM;
            
            //assert statement
            System.assert(false);
            
        } catch (Exception e) {
            
            //assert statement
            System.assert(true);
        }                                   
        
        //Test stop here
        Test.stopTest();                                                
    }
    
    //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
    static testMethod void testPopulateInitialVisitDate() {
    
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today(), RecordTypeId = recordTypes[0]);
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0]);
                                                         
            //Create Opportunity record
            Opportunity opportunity_3 = new Opportunity(Name = 'Opportunity Test3', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0]);
            
            //Create Opportunity record
            Opportunity opportunity_4 = new Opportunity(Name = 'Opportunity Test4', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0]);
                                                         
            //Create Opportunity record
            Opportunity opportunity_5 = new Opportunity(Name = 'Opportunity Test5', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0]);
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            opportunities.add(opportunity_3);
            opportunities.add(opportunity_4);
            opportunities.add(opportunity_5);
            
            //insert Opprotunity
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
            
            //Event
            Event ev_3 = new Event(WhatId = opportunities[3].Id, StartDateTime = System.today().addDays(-3), ActivityDateTime = System.today().addDays(-3), ActivityDate = System.today().addDays(-3),
                                   Cancelled_Did_Not_Occur__c = false, EndDateTime = System.today().addDays(1),Event_Type__c = 'In Person Visit',
                                   Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
            
            //Event
            Event ev_4 = new Event(WhatId = opportunities[4].Id, StartDateTime = System.today().addDays(-4), ActivityDateTime = System.today().addDays(-4), ActivityDate = System.today().addDays(-4),
                                   Cancelled_Did_Not_Occur__c = false, EndDateTime = System.today().addDays(1),Event_Type__c = 'In Person Visit',
                                   Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
            
            //Adding records in the list
            events.add(ev_1);
            events.add(ev_2);
            events.add(ev_3);
            events.add(ev_4);
            
            //Enabling triggers again
            Util.byPassAllTriggers = false;
            
            //Insert events
            insert events;
            
            //Diabling triggers again
            Util.byPassAllTriggers = true;
            
            //Asserting for the results
            opportunities = [SELECT ID, Initial_Visit_Date__c FROM Opportunity ORDER BY Name ASC LIMIT 6];
            System.assertEquals(System.today(),opportunities[0].Initial_Visit_Date__c);
            System.assertEquals(System.today().addDays(-2),opportunities[1].Initial_Visit_Date__c);
            System.assertEquals(null,opportunities[2].Initial_Visit_Date__c);
            System.assertEquals(System.today().addDays(-3),opportunities[3].Initial_Visit_Date__c);
            System.assertEquals(System.today().addDays(-4),opportunities[4].Initial_Visit_Date__c);
            
            //Program__c prog = [select id from Program__c limit 1];
            Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
            insert prog;
        
            //List to hold the warm lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            //Warm lead
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Test Warm Lead 1', Grade__c = '1', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', Primary_Program__c = prog.Id);
            
            Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test Warm Lead 2', Grade__c = '1', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', Primary_Program__c = prog.Id);
                                                        
            //Adding records into the list
            warmLeads.add(warmLead_1);
            warmLeads.add(warmLead_2);
            
            //insert warm leads
            insert warmLeads;
            
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Opportunity__c = opportunities[2].Id, Warm_Lead__c = warmLeads[0].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_3 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[1].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_4 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[3].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_5 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            warmLeadMtMs.add(warmLeadMtM_3);
            warmLeadMtMs.add(warmLeadMtM_4);
            warmLeadMtMs.add(warmLeadMtM_5);
            
            //Test will start from here
            Test.startTest();
            
            //Enabling trigger again
            Util.byPassAllTriggers = false;
        
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_Visit_Date__c, Name FROM Warm_Lead__c ORDER BY Name ASC LIMIT 4];
            System.assertEquals(System.today().addDays(-3), warmLeads[0].Initial_Visit_Date__c);
            System.assertEquals(System.today().addDays(-4), warmLeads[1].Initial_Visit_Date__c);
            
            //Update Case
            warmLeadMtMs[4].Warm_Lead__c = warmLeads[0].Id;
            warmLeadMtMs[2].Warm_Lead__c = warmLeads[0].Id;
            
            //Enabling trigger again
            Util.byPassAllTriggers = false;
            
            //update Warm leads
            update warmLeadMtMs; 
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_Visit_Date__c, Name FROM Warm_Lead__c ORDER BY Name ASC LIMIT 4];
            System.assertEquals(System.today().addDays(-4), warmLeads[0].Initial_Visit_Date__c);
            System.assertEquals(null, warmLeads[1].Initial_Visit_Date__c);
            
            //deleting case
            delete warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_Visit_Date__c, Name FROM Warm_Lead__c ORDER BY Name ASC LIMIT 4];
            System.assertEquals(null, warmLeads[0].Initial_Visit_Date__c);
            System.assertEquals(null, warmLeads[1].Initial_Visit_Date__c);
            
            //Stop test here
            Test.stopTest();
        }
    }
    
    //Added By - Abhinav Sharma - 08/24/2015 - CR-20140613-5790
    static testMethod void testpopulatePAsAndActivityFieldsOnWarmLead() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today(), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(3));
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(2),
                                                         Initial_Activity_Date__c = System.today().addDays(5));
                                                         
            //Create Opportunity record
            Opportunity opportunity_3 = new Opportunity(Name = 'Opportunity Test3', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Initial_Activity_Date__c = null);
            
            //Create Opportunity record
            Opportunity opportunity_4 = new Opportunity(Name = 'Opportunity Test4', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = System.today().addDays(5),
                                                         Initial_Activity_Date__c = System.today().addDays(3));
                                                         
            //Create Opportunity record
            Opportunity opportunity_5 = new Opportunity(Name = 'Opportunity Test5', StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 4.00,
                                                         CloseDate = Date.today().addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null,
                                                         Initial_Activity_Date__c = System.today().addDays(5));
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            opportunities.add(opportunity_3);
            opportunities.add(opportunity_4);
            opportunities.add(opportunity_5);
            
            //insert Opprotunity
            insert opportunities;
            
            //Program__c prog = [select id from Program__c limit 1];
            Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', 
                                                Create_Memberships__c = 'Yes');
            insert prog;
        
            //List to hold the warm lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            //Warm lead
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Test Warm Lead 1', Grade__c = '1', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
            
            Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test Warm Lead 2', Grade__c = '2', Lead_Date__c = Date.today(),
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', 
                                                        Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
                                                        
            //Adding records into the list
            warmLeads.add(warmLead_1);
            warmLeads.add(warmLead_2);
            
            //insert warm leads
            insert warmLeads;
            
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[2].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_3 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[1].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_4 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[3].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_5 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            warmLeadMtMs.add(warmLeadMtM_3);
            warmLeadMtMs.add(warmLeadMtM_4);
            warmLeadMtMs.add(warmLeadMtM_5);
            
            //Test will start from here
            Test.startTest();
            
            //Enabling trigger again
            Util.byPassAllTriggers = false;
        
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_PA_Date__c, Initial_Activity_Date__c, Name FROM Warm_Lead__c 
                            ORDER BY Grade__c ASC LIMIT 4];
            
            System.assertEquals(2, warmLeads.size());
            System.assertEquals(System.today().addDays(3), warmLeads[0].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(3), warmLeads[0].Initial_Activity_Date__c);
            System.assertEquals(System.today().addDays(2), warmLeads[1].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(5), warmLeads[1].Initial_Activity_Date__c);
            
            //Enabling trigger again
            Util.byPassAllTriggers = true;
            
            //Upate Warm Leads
            opportunities[2].Initial_PA_Date__c = System.today().addDays(2);
            opportunities[1].Initial_Activity_Date__c = System.today().addDays(3);
            update opportunities;
            
            //Enabling trigger again
            Util.byPassAllTriggers = false;
            
            //Update warm Lead
            warmLeadMtMs[0].Warm_Lead__c = warmLeads[1].Id;
            update warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_PA_Date__c, Initial_Activity_Date__c, Name FROM Warm_Lead__c 
                            ORDER BY Grade__c ASC LIMIT 4];
            System.assertEquals(2, warmLeads.size());
            System.assertEquals(System.today().addDays(2), warmLeads[0].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(3), warmLeads[0].Initial_Activity_Date__c);
            System.assertEquals(System.today().addDays(2), warmLeads[1].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(3), warmLeads[1].Initial_Activity_Date__c);
            
            //Stop test here
            Test.stopTest();
            
            //Delete use case
            List<Warm_Lead_MtM__c> mtmsToDelete = new List<Warm_Lead_MtM__c>();
            mtmsToDelete.add(warmLeadMtMs[1]);
            mtmsToDelete.add(warmLeadMtMs[2]);
            delete mtmsToDelete;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_PA_Date__c, Initial_Activity_Date__c, Name FROM Warm_Lead__c 
                            ORDER BY Grade__c ASC LIMIT 4];
            System.assertEquals(2, warmLeads.size());
            System.assertEquals(System.today().addDays(5), warmLeads[0].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(3), warmLeads[0].Initial_Activity_Date__c);
            System.assertEquals(System.today().addDays(3), warmLeads[1].Initial_PA_Date__c);
            System.assertEquals(System.today().addDays(5), warmLeads[1].Initial_Activity_Date__c);
            
            //Remaining warm lead Mtms
            warmLeadMtMs = [SELECT ID FROM Warm_Lead_MtM__c];
            
            //Delete Warm Lead MTms
            delete warmLeadMtMs;
            
            //Asserting for the results
            warmLeads = [SELECT ID, Initial_PA_Date__c, Initial_Activity_Date__c, Name FROM Warm_Lead__c 
                            ORDER BY Grade__c ASC LIMIT 4];
            System.assertEquals(2, warmLeads.size());
            System.assertEquals(null, warmLeads[0].Initial_PA_Date__c);
            System.assertEquals(null, warmLeads[0].Initial_Activity_Date__c);
            System.assertEquals(null, warmLeads[1].Initial_PA_Date__c);
            System.assertEquals(null, warmLeads[1].Initial_Activity_Date__c);
        }
    }        
}