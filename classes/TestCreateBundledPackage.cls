@isTest(seeAllData=false)
private class TestCreateBundledPackage {
    //This class will now of no use and will delete in future release
    /*static testmethod void testUpdateProgramDetails() { 
        //Bypass Dupeblocker
        Util.IsTest(true);         
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        // create account/contact to test with
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcon = TestUtilities.CreateNewContact(acc, false); 
        testcon.Email = 'some_test_12321@advisory.com';
        insert testcon;
        System.debug('***** TEST CONTACT: ' + testcon);
        
        // create test programs
        list<Program__c> testprogs = new list<Program__c>();
        Program__c p1 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TEST', 'No', '&^%', false);
        p1.Applicable_Segments__c = 'US Corporate';
        p1.Available_to_Bundle__c = true;
        testprogs.add(p1);
        Program__c p2 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TEST', 'No', '&^%', false);
        p2.Applicable_Segments__c = 'US Corporate';
        p2.Available_to_Bundle__c = true;
        testprogs.add(p2);
        Program__c p3 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TEST', 'No', '&^%', false);
        p3.Applicable_Segments__c = 'US Corporate';
        p3.Available_to_Bundle__c = true;
        testprogs.add(p3);  
        Program__c p4 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TEST', 'No', null, false);
        p3.Applicable_Segments__c = 'US Corporate';
        p3.Available_to_Bundle__c = true;
        testprogs.add(p4);  
        // insert the programs
        insert testprogs;
        //testprogs[0].id  
        Program__c p1Requeried = [select id, name from Program__c where id=:p1.id];
        Program__c p2Requeried = [select id, name from Program__c where id=:p2.id];
        Program__c p3Requeried = [select id, name from Program__c where id=:p3.id];
        Program__c p4Requeried = [select id, name from Program__c where id=:p4.id];
        
        System.debug('*** TEST PROG: ' + testprogs);
        
        // START TEST
        Test.StartTest();
        
        // create a test opportunity
        Opportunity testopp = TestUtilities.CreateNewOpportunity(acc.id, false);
        testopp.StageName = 'Closed Won';
        testopp.CloseDate = system.today();
        testopp.Program__c = p1Requeried.Id;
        testopp.Is_the_Evaluation_Competitive__c = 'Yes';
        testopp.Physician_Competitors__c = 'test';
        insert testopp;
        System.debug('***** testprogs[0]: ' + testprogs[0]);
        
        Campaign cpn1 = new Campaign();
        cpn1.Name = p1Requeried.Name;
        cpn1.IsActive = true;
        cpn1.type = 'Marketing Warming Effort';
        cpn1.Status = 'In Progress';
        cpn1.Secondary_Programs__c = p1Requeried.Name;
        insert cpn1;
        System.assertNotEquals(null,cpn1.id);
        
        Campaign cpn2 = new Campaign();
        cpn2.Name = testprogs[1].Name;
        cpn2.IsActive = true;
        cpn2.type = 'Marketing Warming Effort';
        cpn2.Status = 'In Progress';
        cpn2.Secondary_Programs__c = testprogs[1].Name;
        insert cpn2;
        System.assertNotEquals(null,cpn2.id);
        
        Campaign cpn3 = new Campaign();
        cpn3.Name = testprogs[2].Name;
        cpn3.IsActive = true;
        cpn3.type = 'Marketing Warming Effort';
        cpn3.Status = 'In Progress';
        cpn3.Secondary_Programs__c = testprogs[2].Name;
        insert cpn3;
        System.assertNotEquals(null,cpn3.id);
        
        Campaign cpn4 = new Campaign();
        cpn4.Name = p3Requeried.Name;
        cpn4.IsActive = true;
        cpn4.type = 'Marketing Warming Effort';
        cpn4.Status = 'In Progress';
        cpn4.Secondary_Programs__c = p3Requeried.Name;
        insert cpn4;
        System.assertNotEquals(null,cpn4.id);
        
        System.debug('***** CAMPAIGN 1: ' + cpn1);
        System.debug('***** CAMPAIGN 2: ' + cpn2);
        System.debug('***** CAMPAIGN 3: ' + cpn3);
        System.debug('***** CAMPAIGN 4: ' + cpn4);
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = testopp.Id,
            ContactId = testcon.Id
            );
        insert ocr;

        Warm_Lead__c wl = new Warm_Lead__c(Name = 'testwl');
        insert wl;
        
        Warm_Lead_MtM__c mtm0 = new Warm_Lead_MtM__c();
        mtm0.Opportunity__c = testopp.Id;
        mtm0.Warm_Lead__c = wl.Id;
        insert mtm0;
        
        ApexPages.standardController stdcon = new ApexPages.standardController(testopp);
        test.setCurrentPage(Page.CreateBundledPackage);
        zzzCreateBundledPackage con0 = new zzzCreateBundledPackage(stdcon);   // no id provided
        ApexPages.currentPage().getParameters().put('oid',testopp.Id);
        zzzCreateBundledPackage con = new zzzCreateBundledPackage(stdcon);
        System.debug('***** CreateBundledPackage - TEST 1: '+ con);
 
        // test Evaluated
        con.progs[0].Evaluated__c = true;
        con.clickPresented();
        con.DoClone();

        // test Presented
        zzzCreateBundledPackage con1 = new zzzCreateBundledPackage(stdcon);
        con1.progs[1].Presented__c = true;
        con1.clickPresented();
        con1.DoClone();

        // test Presented unchecked
        zzzCreateBundledPackage con6 = new zzzCreateBundledPackage(stdcon);
        con6.progs[1].Presented__c = false;
        con6.clickPresented();
        con6.DoClone();

        // test 2nd Evaluated
        zzzCreateBundledPackage con2 = new zzzCreateBundledPackage(stdcon);
        con2.progs[0].Evaluated__c = true;
        con2.progs[1].Evaluated__c = true;
        con2.clickPresented();
        String ChildOppID = con2.progs[0].Bundled_Opportunity_ID__c;
        con2.DoClone();
    
        System.debug('***** TESTOP: ' + testopp);
        // test no program
        testOpp = [SELECT Id FROM Opportunity WHERE Id = :testOpp.Id];
        testopp.Program__c = null;
        update testopp;
        zzzCreateBundledPackage con3 = new zzzCreateBundledPackage(stdcon);
        
        // test no program line
        testopp.Program__c = p3Requeried.Id;
        System.debug('***** TESTOP Marketing_Warming_Effort__c: ' + testopp.Marketing_Warming_Effort__c);
        update testopp;

        zzzCreateBundledPackage con4 = new zzzCreateBundledPackage(stdcon);

        // test using child opp
        ApexPages.currentPage().getParameters().put('oid',ChildOppID);
        zzzCreateBundledPackage con5 = new zzzCreateBundledPackage(stdcon);
        con5.Cancel();
        test.StopTest();
        
        // get the bundled opportunities that were created from the test opp
        List<Opportunity> bundledOpps = [SELECT Name, Id FROM Opportunity WHERE Bundle_Parent__c = :testopp.Id];
        system.assertEquals(2, bundledOpps.size());
    }
    
    static testmethod void testChildOpportunityHasDifferentNameThanParent() { 
        //Bypass Dupeblocker
        Util.IsTest(true);         
        
        //Util.IsTesting = true;
        // create account/contact to test with
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcon = TestUtilities.CreateNewContact(acc, false);
        testcon.Email = 'some_test_12321@advisory.com';
        insert testcon;
        System.debug('***** TEST CONTACT: ' + testcon);
        
        // create test programs
        list<Program__c> testprogs = new list<Program__c>();
        Program__c p1 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TEST', 'No', '&^%', false);
        p1.Applicable_Segments__c = 'US Corporate';
        p1.Available_to_Bundle__c = true;
        testprogs.add(p1);
        Program__c p2 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TST', 'No', '&^%', false);
        p2.Applicable_Segments__c = 'US Corporate';
        p2.Available_to_Bundle__c = true;
        testprogs.add(p2);
        Program__c p3 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TET', 'No', '&^%', false);
        p3.Applicable_Segments__c = 'US Corporate';
        p3.Available_to_Bundle__c = true;
        testprogs.add(p3);  
        Program__c p4 = TestUtilities.CreateNewProgram('Core Clinical Marketer', 'TES', 'No', null, false);
        p3.Applicable_Segments__c = 'US Corporate';
        p3.Available_to_Bundle__c = true;
        testprogs.add(p4);  
        // insert the programs
        insert testprogs;
        //testprogs[0].id  
        Program__c p1Requeried = [select id, name from Program__c where id=:p1.id];
        Program__c p2Requeried = [select id, name from Program__c where id=:p2.id];
        Program__c p3Requeried = [select id, name from Program__c where id=:p3.id];
        Program__c p4Requeried = [select id, name from Program__c where id=:p4.id];
        
        System.debug('*** TEST PROG: ' + testprogs);
        
        // create a test opportunity
        Opportunity testParentOpp = TestUtilities.CreateNewOpportunity(acc.id, false);
        testParentOpp.StageName = 'Closed Won';
        testParentOpp.CloseDate = system.today();
        testParentOpp.Program__c = p1Requeried.Id;
        testParentOpp.Is_the_Evaluation_Competitive__c = 'Yes';
        testParentOpp.Physician_Competitors__c = 'test';
        insert testParentOpp;

        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testParentOpp);
        test.setCurrentPage(Page.CreateBundledPackage);
        //CreateBundledPackage con0 = new CreateBundledPackage(stdcon); // no id provided
        ApexPages.currentPage().getParameters().put('oid',testParentOpp.Id);
        zzzCreateBundledPackage con = new zzzCreateBundledPackage(stdcon);
        con.progs[1].Evaluated__c = true;
        con.clickPresented();
        con.DoClone();
        test.stopTest();
        List<Opportunity> bundledOpps = [SELECT Name, Id FROM Opportunity WHERE Bundle_Parent__c = :testParentOpp.Id];
        System.assertNotEquals(0,bundledOpps.size());
        Opportunity parentOppty = [select id, name from Opportunity where id=:testParentOpp.Id];
        Opportunity childOppty1 = [select id, name from Opportunity where id=:bundledOpps[0].Id];
        System.assertNotEquals(parentOppty.Name,childOppty1.Name);  
    }*/
}