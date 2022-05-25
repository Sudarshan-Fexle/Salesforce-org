/*
* Purpose         :   Test class for WarmLead_Con
*
* Current Version :   v1.0
*
* Revision Log 	  :   Modfied By -  Neha Sharma - 07/01/2021 - CR-20210517-15151 -  Test Classes issue Fixes & Code Coverage Increase (Modified method i.e "testSelections")
* 																		
**/
@isTest(seeAllData=false)
private class WarmLead_ConTest {
    
    static testmethod void testwarmleadcon() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Removed 4/21/11 for new data JN
        //list<Contact> testcons = [select id from Contact limit 1];
        //list<Lead> testleads = [select id from Lead limit 1];
        list<Contact> testcons = new list<Contact>();
        list<Lead> testleads = new list<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testcons.add(new Contact(LastName = 'testcon' + String.valueOf(i), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            testleads.add(new Lead(LastName = 'testlead' + String.valueOf(i), Company = 'testcompany'));
        }
        insert testcons;
        insert testleads;
        
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            StartDate = system.today(),
            Type = 'Paid Event',
            Channel__c = 'Prospect Meeting'
        );
        insert testcamp;
        
        list<CampaignMember> testcms = new list<CampaignMember>();
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            ContactID = testcons[0].id,
            Contact_Level__c = 'CXO',
            Status = 'Responded'
        ));
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            LeadID = testleads[0].id,
            Contact_Level__c = 'CXO',
            Status = 'Responded'
        ));
        insert testcms;
        set<id> testcmids = new set<Id>();
        for (CampaignMember cm : testcms) {
            testcmids.add(cm.id);
        }
        test.startTest();
        test.setCurrentPage(Page.MakeWarmLeads);
        ApexPages.CurrentPage().getParameters().put('camp',testcamp.id);
        WarmLead_Con wlc = new WarmLead_Con();
        
        Campaign returnedcamp = wlc.getcamp();
        list<WarmLead_Con.cmember> returnedcmembers = wlc.getCMembers();
        
        PageReference testcampdetail = wlc.DoneWithPage();
        system.assertEquals(null, wlc.refreshlist());
        test.stopTest();
        
        system.AssertEquals(testcamp.id, returnedcamp.id); //right campaign
        system.assertEquals(testcms.size(),returnedcmembers.size()); //right size cmember list
        
        Integer testcounter = 1;
        for (WarmLead_Con.cmember cmember : returnedcmembers) {
            if (cmember.cm.id == testcms[0].id) {
                testcounter *= 2;
            }
            if (cmember.cm.id == testcms[1].id) {
                testcounter *= 3;
            }
        }
        system.assertEquals(6,testcounter); //hit each cm in testcms once
        
        
        
    }
    
    //Modfied By -  Neha Sharma - 07/01/2021 - CR-20210517-15151 -  Test Classes issue Fixes & Code Coverage Increase
    static testmethod void testSelections()
    {
        //Removed 4/21/11 for new data JN
        //list<Contact> testcons = [select id from Contact limit 1];
        //list<Lead> testleads = [select id from Lead limit 1];
        list<Contact> testcons = new list<Contact>();
        
        list<Lead> testleads = new list<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testcons.add(new Contact(LastName = 'testcon' + String.valueOf(i), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            testleads.add(new Lead(LastName = 'testlead' + String.valueOf(i), Company = 'testcompany'));
        }
        insert testcons;
        insert testleads;
        
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            Type = 'Prospect Meeting',
            StartDate = system.today(),
            Channel__c = 'Prospect Meeting'
        );
        insert testcamp;
        
        list<CampaignMember> testcms = new list<CampaignMember>();
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            ContactID = testcons[0].id,
            Contact_Level__c = 'CXO',
            Status = 'Responded',
            Member_Attendee_Status__c = 'Registered',
            Warm_Lead_Status__c = 'Pending'
        ));
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            LeadID = testleads[0].id,
            Contact_Level__c = 'CXO',
            Status = 'Responded',
            Member_Attendee_Status__c = 'Registered',
            Warm_Lead_Status__c = 'Pending'
        ));
        insert testcms;
        set<id> testcmids = new set<Id>();
        for (CampaignMember cm : testcms) {
            testcmids.add(cm.id);
        }
        
        Test.startTest();
        
        test.setCurrentPage(Page.MakeWarmLeads);
        ApexPages.CurrentPage().getParameters().put('camp',testcamp.id);
        WarmLead_Con wlc = new WarmLead_Con();
        
        //Select some of list and only create Warm Leads for those.
        list<WarmLead_Con.cmember> returnedcmembers = wlc.getCMembers();
        for (WarmLead_Con.cmember cmember : returnedcmembers) {
            if (cmember.cm.id == testcms[0].id) cmember.Selected = True;
            if (cmember.cm.id == testcms[1].id) cmember.Selected = False;
        }
        wlc.setCMembers(returnedcmembers);
        
        //Uncommented By -  Neha Sharma - 07/01/2021 - CR-20210517-15151 -  Test Classes issue Fixes & Code Coverage Increase
        PageReference testpr;
        try {
            
            testpr = wlc.MakeWarmLeads();
            
        }
        Catch(Exception e) {
            
        }
         
        //test Select All function
        wlc.setIsAllSelected(True);
        testpr = wlc.SelectAll();
        returnedcmembers = wlc.getCMembers();
        system.assertEquals(2, returnedcmembers.size());
        system.assertEquals(True, returnedcmembers[0].Selected);
        system.assertEquals(True, returnedcmembers[1].Selected);
        testpr = wlc.MakeWarmLeads(); //should only work on one, since the other already had a warm lead
        
        wlc.setIsAllSelected(False);
        testpr = wlc.SelectAll();
        returnedcmembers = wlc.getCMembers();
        system.assertEquals(2, returnedcmembers.size());
        system.assertEquals(False, returnedcmembers[0].Selected);
        system.assertEquals(False, returnedcmembers[1].Selected);
        
        system.assertEquals(False, wlc.getIsAllSelected());
        
        test.StopTest();
        //check Warm Leads were created. Should be 2
        list<Warm_Lead__c> createdWLs = [select id, Lead_Channel__c, Contact_Level__c, Attendee_Status__c, Status__c from Warm_Lead__c where Campaign__c = :testcamp.id];
        
        // make sure both have the correct contact level
        for (Warm_Lead__c wl : createdWLs) {
            system.assertEquals(wl.Contact_Level__c, 'CXO');
            system.assertEquals('Registered', wl.Attendee_Status__c);
            system.assertEquals('Pending',wl.Status__c);
        }
        
        system.assertEquals(2, createdWLs.size());
        system.assertEquals('Prospect Meeting', createdWLs[0].Lead_Channel__c);
        
        //Make sure Warm Lead and Campaign Member are connected.
        list<CampaignMember> convertedcms = [select id from CampaignMember where CampaignID = :testcamp.id and Warm_Lead_Created__c != null];
        system.assertEquals(2, convertedcms.size());
        
        //Check Warm Lead counter on Campaign. Should be at 2
        testcamp = [select Total_Warm_Leads__c from Campaign where id = :testcamp.id];
        system.assertEquals(2, testcamp.Total_Warm_Leads__c); 
    }
    
    static testmethod void testSorting()
    {
        //Removed 4/21/11 JN
        //list<Contact> testcons = [select id from Contact limit 1];
        //list<Lead> testleads = [select id from Lead limit 1];
        list<Contact> testcons = new list<Contact>();
        list<Lead> testleads = new list<Lead>();
        for (Integer i = 0; i < 2; i++) {
            testcons.add(new Contact(LastName = 'testcon' + String.valueOf(i), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            testleads.add(new Lead(LastName = 'testlead' + String.valueOf(i), Company = 'testcompany'));
        }
        insert testcons;
        insert testleads;
        
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            Channel__c = 'Prospect Meeting',
            StartDate = system.today()
        );
        insert testcamp;
        
        Boolean FoundRegistered = false;
        
        list<CampaignMemberStatus> cmstatuses = [select id, Label, HasResponded from CampaignMemberStatus where CampaignID =:testcamp.id]; 
        
        for (CampaignMemberStatus cms : cmstatuses) {
            if (cms.Label == 'Registered') {
                FoundRegistered = true;
                if (!cms.HasResponded) {
                    cms.HasResponded = true;
                    update cms;
                }
            }
        }
        if (!FoundRegistered) {
            CampaignMemberStatus newcms = new CampaignMemberStatus(
                CampaignID = testcamp.id,
                SortOrder = cmstatuses.size() + 1,
                HasResponded = true,
                Label = 'Registered');
            //insert newcms;
        }
        
        test.setCurrentPage(Page.MakeWarmLeads);
        ApexPages.CurrentPage().getParameters().put('camp',testcamp.id);
        WarmLead_Con wlc = new WarmLead_Con();
        //wlc.fixCampaignMemberStatuses();
        
        list<CampaignMember> testcms = new list<CampaignMember>();
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            LeadID = testleads[0].id,
            Status = 'Registered'
        ));
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            ContactID = testcons[1].id,
            Status = 'Responded'
        ));
        insert testcms;
        
        test.StartTest();
        wlc = new WarmLead_Con(); //get requery of cmembers
        
        list<WarmLead_Con.cmember> returnedcmembers = wlc.getCMembers();
        system.assertEquals(1,returnedcmembers.size());
        
        wlc.sortByStatus();
        returnedcmembers = wlc.getCMembers();
        system.assertEquals(1,returnedcmembers.size());
        system.assertEquals(testcms[1].id, returnedcmembers[0].cm.id);
        
        wlc.sortByStatus();
        returnedcmembers = wlc.getCMembers();
        system.assertEquals(1,returnedcmembers.size());
        
        test.StopTest();        
    }
    
    static testmethod void testfixstatuses()
    {
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            StartDate = system.today()
        );
        insert testcamp;
        
        CampaignMemberStatus newcms = new CampaignMemberStatus(
            CampaignId = testcamp.id,
            SortOrder = 1,
            HasResponded = true,
            Label = 'Registered');
        //insert newcms;
        
        list<CampaignMemberStatus> startstatuses = [select id from CampaignMemberStatus where CampaignID = :testcamp.id];
        system.assertEquals(0, startstatuses.size());
        
        test.startTest();
        test.setCurrentPage(Page.MakeWarmLeads);
        ApexPages.CurrentPage().getParameters().put('camp',testcamp.id);
        WarmLead_Con wlc = new WarmLead_Con();
        
        // wlc.fixCampaignMemberStatuses();
        
        test.stopTest();
        
        list<CampaignMemberStatus> endstatuses = [select id from CampaignMemberStatus where CampaignID = :testcamp.id];
        system.assertEquals(0, endstatuses.size());
        
        
    }
    
    static testmethod void testnocamp()
    {
        //no Campaign ID supplied
        
        test.startTest();
        test.setCurrentPage(Page.MakeWarmLeads);
        WarmLead_Con wlc = new WarmLead_Con();
        
        system.assertEquals(0,wlc.getCMembers().size());
        
        test.stopTest();        
        
    }
    
    static testmethod void testfilters()
    {
        //Removed and replaced with new data 4/21/11 JN
        //list<Contact> testcons = [select id from Contact limit 1];
        //list<Lead> testleads = [select id from Lead limit 1];
        list<Contact> testcons = new list<Contact>();
        list<Lead> testleads = new list<Lead>();
        for (Integer i = 0; i < 2; i++) {
            testcons.add(new Contact(LastName = 'testcon' + String.valueOf(i), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            testleads.add(new Lead(LastName = 'testlead' + String.valueOf(i), Company = 'testcompany'));
        }
        insert testcons;
        insert testleads;
        
        
        Campaign testcamp = new Campaign(
            Name = 'Warm Lead Test',
            StartDate = system.today()
        );
        insert testcamp;
        
        Boolean FoundRegistered = false;
        list<CampaignMemberStatus> cmstatuses = [select id, Label, HasResponded from CampaignMemberStatus where CampaignId = :testcamp.id];
        for (CampaignMemberStatus cms : cmstatuses) {
            if (cms.Label == 'Registered') {
                FoundRegistered = true;
                if (!cms.HasResponded) {
                    cms.HasResponded = true;
                    update cms;
                }
            }
        }
        if (!FoundRegistered) {
            CampaignMemberStatus newcms = new CampaignMemberStatus(
                CampaignId = testcamp.id,
                SortOrder = cmstatuses.size() + 1,
                HasResponded = true,
                Label = 'Registered');
            //insert newcms;
        }
        
        test.setCurrentPage(Page.MakeWarmLeads);
        ApexPages.CurrentPage().getParameters().put('camp',testcamp.id);
        WarmLead_Con wlc = new WarmLead_Con();
        //wlc.fixCampaignMemberStatuses();
        
        list<CampaignMember> testcms = new list<CampaignMember>();
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            ContactID = testcons[0].id,
            
            Status = 'Responded'
        ));
        testcms.add(new CampaignMember(
            CampaignId = testcamp.id,
            LeadID = testleads[0].id,
            
            Status = 'Registered'
        ));
        insert testcms;
        
        test.startTest();
        wlc = new WarmLead_Con();
        
        system.assertEquals('Show All', wlc.getcurrentFilter());
        list<SelectOption> testoptions = wlc.getfilteroptions();
        system.assertEquals(3,testoptions.size()); //'Show All', 'Registered', 'Responded'
        system.assertEquals(1,wlc.getCMembers().size());
        
        wlc.setcurrentFilter('Registered');
        list<WarmLead_Con.cmember> testcmembers = wlc.getCMembers();
        system.assertEquals(0, testcmembers.size());
        
        test.stopTest();        
        
    }
    
}