@isTest
private class TestWarmLeadMtM_UpdateOppFields {
    /*
    Purpose:    Test Trigger WarmLeadMtM_UpdateOppFields
    
    Create By:          Jeremy Nottingham (Synaptic) - 1/20/2011
    
    Last Modified By:   Nathan Banas (Synaptic) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       V_1.0 - (PE) Created code
                        V_1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        V_1.2 - Test method "UnitTest" modified - Bhavi Sharma - CR-20130417-2892 - 12/13/2013
                        V_1.3 - (SUNJ) Update Proposal_Value__c with Amount
                        V_1.4 - Modified By - Abhinav Sharma - CR-20140808-6940 - 08/27/2014
                        V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.
			V_1.6 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    Code Coverage as of 1/25/2011: 95%
    */
    
  
    static testmethod void UnitTest() {
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Disable all the triggers 
        Util.BypassAllTriggers = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
    
        
        //Removed 4/25/11 for new data JN
        //List<Warm_Lead__c> wls = [select id from Warm_Lead__c limit 5];
        list<Warm_Lead__c> wls = new list<Warm_Lead__c>();
        for (Integer i = 0; i < 5; i++) {
            
            //Code modified(Lead Date field added into Warm Lead instance) - Bhavi Sharma - CR-20130417-2892
            wls.add(new Warm_Lead__c(
                Name = 'testwarmlead', Lead_Date__c = Date.today().addDays(i-2)
                ));
        }
        insert wls;

        // let's make sure we have enough records to test with: 
        System.assertEquals( wls.size(), 5);
        
        //Removed 4/25/11 for new data JN
        //List<Opportunity> opps = [select Id, Warm_Lead__c, Count_of_Warm_Leads__c from Opportunity where CloseDate >= :system.today() limit 5] ;
        list<Opportunity> opps = new list<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            opps.add(new Opportunity(
                StageName = 'Pending',
                CloseDate = system.today().addDays(32),
                Name = 'testopp',
                Main_Contact__c = cont.Id,
                Initial_Visit_Date__c = system.today(), Sales_Pursuit_Products__c = 'APS'
                ));
        }
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        insert opps;
        
        opps = [select Id, Warm_Lead__c from Opportunity where id in :opps];    
        
        // TEST WITH ONE OPP 
        Opportunity opp = opps[0];
        
        
        //Code modified - Bhavi Sharma - CR-20130417-2892 - 11/13/2013
        //DateTime DTStart = DateTime.Now();
        Date DTStart = Date.today();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
                
        //Insert Event
        Event event  = new Event( WhatId = opp.Id, StartDateTime = DTStart, ActivityDateTime = DTStart,
                                        ActivityDate = DStart, EndDateTime = DTStart, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT,
                                        Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT, Executive_Type__c = 'CXO', Visit_Location__c = 'Campus',
                                        Grade__c = 'C');
        insert event;
        
        //Enable all the triggers 
        Util.BypassAllTriggers = false;
        
        /*----V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.
        // capturing original count of warm leads
        Decimal oldCount = (opp.Count_of_Warm_Leads__c == null)? 0 : opp.Count_of_Warm_Leads__c;*/
        
        // create new WL_MTMs   
        List<Warm_Lead_MtM__c> newWlmtms = new List <Warm_Lead_MtM__c>();
        
        for (Warm_Lead__c wl : wls)
        {
            Warm_Lead_MtM__c wlmtm = new Warm_Lead_MtM__c(Opportunity__c = opp.id , Warm_Lead__c = wl.id );
            newWlmtms.add(wlmtm);
        }
    
        //Start test from here
        test.StartTest();   
        
        insert newWlmtms;
        
        test.stopTest();
        
        /*----V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.*/
        // checking fields   
        opp = [select Id, Warm_Lead__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        //System.assertEquals(opp.Count_of_Warm_Leads__c, oldCount + 5 );
        System.assertEquals(opp.Warm_Lead__c, true);
        System.assertEquals(2, opp.Count_of_Sourced_Warm_Leads__c);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //System.debug('Updateing Opportunity Now:::::');
        //event.StartDateTime = DTStart + 10;
        //event.ActivityDateTime = DTStart + 10;
        //event.ActivityDate = DStart + 10;
        //event.EndDateTime = DTStart + 10;
        //update event;
     
        //This update should also update the Initial update date to Opportunity
        //opp = [Select Initial_Visit_Date__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        //System.assertEquals(DStart + 10, opp.Initial_Visit_Date__c);
        //System.assertEquals(5, opp.Count_of_Sourced_Warm_Leads__c);
         
        //Update Event to check if the Opprotunity Initial date update along with Sourced lead count information
        event.StartDateTime = DTStart;
        event.ActivityDateTime = DTStart;
        event.ActivityDate = DStart;
        event.EndDateTime = DTStart;
        update event;
        
        //This update should also update the Initial update date to Opportunity
        opp = [Select Initial_Visit_Date__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        //System.assertEquals(DStart, opp.Initial_Visit_Date__c);
        //System.assertEquals(2, opp.Count_of_Sourced_Warm_Leads__c);
        
        //Update opportunity id on MTMs
        for(Warm_Lead_MtM__c wlMtM : newWlmtms)
            wlMtM.Opportunity__c = opps[1].Id;
        update newWlmtms;
        
        // checking fields   
        opp = [select Initial_Visit_Date__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        Opportunity opp1 = [select Initial_Visit_Date__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opps[1].id];
        System.assertEquals(0, opp.Count_of_Sourced_Warm_Leads__c);
        //System.assertEquals(null, opp1.Initial_Visit_Date__c);
        //System.assertEquals(system.today(), opp1.Initial_Visit_Date__c);
        System.assertEquals(2, opp1.Count_of_Sourced_Warm_Leads__c);
        
        /*//Update opportunity id on MTMs
        for(Warm_Lead_MtM__c wlMtM : newWlmtms)
            wlMtM.Opportunity__c = opp.Id;
        update newWlmtms;
        
        // checking fields   
        opp = [select Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        opp1 = [select Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opps[1].id];
        System.assertEquals(2, opp.Count_of_Sourced_Warm_Leads__c);
        System.assertEquals(0, opp1.Count_of_Sourced_Warm_Leads__c);
        
        //Update Lead Date to future
        wls[0].Lead_Date__c = Date.today() + 5;
        update wls[0];
        
        // checking fields   
        opp = [select Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        System.assertEquals(1, opp.Count_of_Sourced_Warm_Leads__c);
        
        //Update Lead Date to future
        wls[0].Lead_Date__c = Date.today() - 5;
        update wls[0];
        
        // checking fields   
        opp = [select Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        System.assertEquals(2, opp.Count_of_Sourced_Warm_Leads__c);
        
        
        //Delete the first WL record
        delete wls[0];
        
        // checking fields   
        opp = [select Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        System.assertEquals(1, opp.Count_of_Sourced_Warm_Leads__c);
        
        // now delete 3 WL_MTMs (we remove 2 and delete 3)
        newWlmtms.remove(0);
        newWlmtms.remove(0);
        delete newWlmtms;
        
        opp = [select Id, Warm_Lead__c, Count_of_Warm_Leads__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ] ;
        System.Debug('opp.id and Warm_Lead__c and Count_of_Warm_Leads__c : '+ opp.Id +' '+ opp.Warm_Lead__c +' '+ opp.Count_of_Warm_Leads__c);
        System.assertEquals(opp.Warm_Lead__c, true);
        System.assertEquals(opp.Count_of_Warm_Leads__c, oldCount + 1 );
        
        list<Warm_Lead_MtM__c> allwls = [select id from Warm_Lead_MtM__c where Opportunity__c = :opp.id];
        delete allwls;
    
        opp = [select Id, Warm_Lead__c, Count_of_Warm_Leads__c, Count_of_Sourced_Warm_Leads__c from Opportunity where id = :opp.id ];
        system.debug('\n\noppid ' + opp.id + ' opp ' + opp);    
        System.assertEquals(false, opp.Warm_Lead__c);
        System.assertEquals( 0,opp.Count_of_Warm_Leads__c );
        System.assertEquals(0, opp.Count_of_Sourced_Warm_Leads__c);*/
    }
 
    static testmethod void UnitTest2() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        //split test into two pieces to avoid governor problems.
        Util.IsTesting = true;
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
            
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();

        list<Opportunity> opps = new list<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            opps.add(new Opportunity(
                StageName = 'Pending',
                CloseDate = system.today().addDays(32),
                Main_Contact__c = cont.Id,
		AccountId = acc.id,Sales_Pursuit_Products__c = 'APS',
                Name = 'testopp', RecordTypeId = recordTypeId
                ));
        }
        insert opps;
        opps = [select Id, Warm_Lead__c from Opportunity where id in :opps];    
        
        // TEST WITH ONE OPP (should be also testing with several opps inserts or updates)
        Opportunity opp = opps[0];
        
        Util.byPassAllTriggers = false;
        //Removed 4/25/11 for new data JN
        //List<Warm_Lead__c> wls = [select id from Warm_Lead__c limit 5];
        list<Warm_Lead__c> wls = new list<Warm_Lead__c>();
        for (Integer i = 0; i < 5; i++) {
            wls.add(new Warm_Lead__c(
                Name = 'testwarmlead'
                ));
        }
        insert wls;
            
        // let's make sure we have enough records to test with: 
        System.assertEquals( wls.size(), 5);
        
        //Removed 4/25/11 JN
        //List<Opportunity> opps = [select Id, Warm_Lead__c, Count_of_Warm_Leads__c from Opportunity where CloseDate >= :system.today() limit 5] ;

        // capturing original count of warm leads
        //Decimal oldCount = (opp.Count_of_Warm_Leads__c == null)? 0 : opp.Count_of_Warm_Leads__c;
        
        // create new WL_MTMs
        List<Warm_Lead_MtM__c> newWlmtms = new List <Warm_Lead_MtM__c>();
        for (Warm_Lead__c wl : wls)
        {
            Warm_Lead_MtM__c wlmtm = new Warm_Lead_MtM__c(Opportunity__c = opp.id , Warm_Lead__c = wl.id );
            newWlmtms.add(wlmtm);
        }
        
        test.StartTest();
        
        insert newWlmtms;
        
        test.stopTest();
        
        // checking fields   
        opp = [select Id, Warm_Lead__c from Opportunity where id = :opp.id ] ;
        
        System.assertEquals(opp.Warm_Lead__c, true);
        //System.assertEquals(opp.Count_of_Warm_Leads__c, oldCount + 5 );
    	
        // now delete 3 WL_MTMs (we remove 2 and delete 3)
        newWlmtms.remove(0);
        newWlmtms.remove(0);
        delete newWlmtms;
        
        opp = [select Id, Warm_Lead__c from Opportunity where id = :opp.id ] ;
        
        System.assertEquals(opp.Warm_Lead__c, true);
        //System.assertEquals(opp.Count_of_Warm_Leads__c, oldCount + 2 );
        
        list<Warm_Lead_MtM__c> allwls = [select id from Warm_Lead_MtM__c where Opportunity__c = :opp.id];
        delete allwls;
            
        opp = [select Id, Warm_Lead__c from Opportunity where id = :opp.id ];
        system.debug('\n\noppid ' + opp.id + ' opp ' + opp);    
        System.assertEquals(false, opp.Warm_Lead__c);
        //System.assertEquals( 0,opp.Count_of_Warm_Leads__c);
    }
 
    static testmethod void UnitTest3() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        //split test into two pieces to avoid governor problems.
        Util.IsTesting = true;
        
        //Disable all the triggers 
        Util.BypassAllTriggers = true;
        
        Account testAcc = new Account(Name='TestAcc');
        
        insert testAcc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
    
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity testOpp = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='TestOpp', Main_Contact__c = cont.Id, StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 1, Initial_Visit_Date__c = System.today().addDays(-5), CloseDate = System.today().addDays(32));
        
        insert testOpp;
        
        List<Warm_Lead__c> warmLeadList = new List<Warm_Lead__c>();
        
        Warm_Lead__c WL1 = new Warm_Lead__c(
            Account__c = testAcc.Id,
            Opportunity__c = null,
            Initial_Visit_Date__c = null);
        
        warmLeadList.add(WL1);
        
        Warm_Lead__c WL2 = new Warm_Lead__c(
            Account__c = testAcc.Id,
            Opportunity__c = testOpp.Id,
            Initial_Visit_Date__c = System.today().addDays(-2));
        
        warmLeadList.add(WL2);
        
        Warm_Lead__c WL3 = new Warm_Lead__c(
            Account__c = testAcc.Id,
            Opportunity__c = testOpp.Id,
            Initial_Visit_Date__c = System.today().addDays(-1));
        
        warmLeadList.add(WL3);
        
        insert warmLeadList;
        
        //Enable all the triggers 
        Util.BypassAllTriggers = false;
        
        Warm_Lead_MtM__c testWLMtM1 = new Warm_Lead_MtM__c(
            Opportunity__c = testOpp.Id,
            Warm_Lead__c = WL1.Id);
        
        Warm_Lead_MtM__c testWLMtM2 = new Warm_Lead_MtM__c(
            Opportunity__c = testOpp.Id,
            Warm_Lead__c = WL2.Id);
        
        Warm_Lead_MtM__c testWLMtM3 = new Warm_Lead_MtM__c(
            Opportunity__c = testOpp.Id,
            Warm_Lead__c = WL3.Id);
        
        test.startTest();
        
        insert testWLMtM1;
        insert testWLMtM2;
        
        test.stopTest();
        
        WL1.Opportunity__c = testOpp.Id;
        update WL1;
        
        insert testWLMtM3;
        
    }

    static testmethod void testErrorHandling() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        //split test into two pieces to avoid governor problems.
        Util.IsTesting = true;
        
        Account testAcc = TestUtilities.CreateNewAccount(true);
        
        Opportunity testOpp = TestUtilities.CreateNewOpportunity(testAcc.Id, false);
        testOpp.StageName = 'Closed Lost';
        testOpp.Primary_Reason_Lost__c = 'Bad Timing';
        testOpp.Re_approach_Opportunity__c = 'No';
        insert testOpp;
        
        Warm_Lead__c WL1 = new Warm_Lead__c(
            Account__c = testAcc.Id,
            Opportunity__c = null,
            Initial_Visit_Date__c = null);
        
        insert WL1;
        
        // run as a non-system-admin user
        User usr = [SELECT Id FROM User WHERE isActive=true AND Profile.Name != 'Finance Ops' AND Profile.Name != 'System Administrator' AND Profile.Name != 'ABC Dataloader' LIMIT 1];
        
        system.runAs(usr) {
            Warm_Lead_MtM__c testWLMtM1 = new Warm_Lead_MtM__c(
                Opportunity__c = testOpp.Id,
                Warm_Lead__c = WL1.Id);
            test.startTest();
            
            try {
                insert testWLMtM1;
            }
            catch(Exception ex) {
                
            }
        }
        
        test.stopTest();
    }
}