/*
    Purpose         :   Test class for the Batch_MembershipSubscriptions class
                
    Create By       :   Victor Hanson
    
    Created Date    :   3/13/2012
    
    Revision Log    :   V1.0 Created
    			V1.1 - Victor Hanson - 10/15/2015 -CR-20140407-4977 - added unit test (testBatchMembershipSubscription_BulkLoad)
			V1.2 - Abhinav Sharma - 10/30/2015 - CR-20140407-4977 - Modified to include "Membership_Status__c" field in the query literal
			V1.2 - Deepak Kumawat - Apollo - Run All Test Failures Fixes
			V1.3 - Dipesh Gupta - Rev mgmt 606 Release, production validation failure fixes - Method "testBatchMembershipSubscription"
                        V1.4 - Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
			V1.5 - Prateek - CR-20211012-15511 - increase code coverage.
*/
@isTest
public with sharing class Test_BatchMembershipSubscriptions {
    
    static testMethod void testBatchMembershipSubscription() {
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
    	Util.bypassEntityPopulation = true;
        
        // create 2 contacts on the same account that are also Adv.com Users
        List<Contact> contactList = new List<Contact>();
        Contact advUserContact1 = TestUtilities.CreateAdvUserContact(false);
        advUserContact1.LastName = 'User1';
        contactList.add(advUserContact1);
        Contact advUserContact2 = TestUtilities.CreateAdvUserContact(new Account(Id=advUserContact1.AccountId), false);
        advUserContact2.LastName = 'User2';
        contactList.add(advUserContact2);
        
        insert contactList;
        
        // CR-20211012-15511 - Start
        Account acc = TestUtilities.CreateNewAccount(true);
        System.assert(acc.Id != null);
        
        Contact con = TestUtilities.CreateNewContact(acc, true);
        System.assert(con.Id != null);
        
        // CR-20211012-15511 - End
        // create 2 programs
        List<Program__c> progList = new List<Program__c>();
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Acronym__c = 'HCAB';
        progList.add(prog1);
        Program__c prog2 = TestUtilities.CreateNewProgram(false);
        prog2.Program_Acronym__c = 'NEC';
        progList.add(prog2);
        insert progList;
        
        // create 2 opportunities
        List<Opportunity> opps = new List<Opportunity>();
        List<Contract__c> contracts = new List<Contract__c>();
        Opportunity opp1 = testUtilities.CreateNewOpportunity(advUserContact1.AccountId, false);
        opp1.CloseDate = system.today();
        opp1.stageName = 'Closed Won';
        opp1.Program__c = prog1.Id;
        opps.add(opp1);
        Opportunity opp2 = testUtilities.CreateNewOpportunity(advUserContact1.AccountId, false);
        opp2.CloseDate = system.today();
        opp2.stageName = 'Closed Won';
        opp2.Program__c = prog2.Id;
        opps.add(opp2);
        insert opps;
        
        // create 2 contracts
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = advUserContact1.AccountId, Program__c = prog1.Id, Source_Opportunity__c=opp1.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp1.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        contracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = advUserContact2.AccountId, Program__c = prog2.Id, Source_Opportunity__c=opp2.Id,
            Start__c = System.Today().addDays(-100), End__c = system.today().addDays(2),
            Contract_Renewal_Opportunity__c = opp2.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        contracts.add(testContract2);
        insert contracts;
        
       
        test.startTest();
        // create 2 memberships
        List<Membership__c> memberships = new List<Membership__c>();
        Membership__c mem1 = new Membership__c();
        mem1.Membership_Status_Text__c = 'Active Member';
        mem1.Account_Name__c = advUserContact1.AccountId;
        mem1.Program__c = prog1.Id;
        mem1.Name = 'test';
        mem1.Active_Contract_Idenfied__c = testContract1.Id;
        mem1.Latest_Contract__c = testContract1.Id;
        memberships.add(mem1);
        Membership__c mem2 = new Membership__c();
        mem2.Membership_Status_Text__c = 'Active Member';
        mem2.Account_Name__c = advUserContact2.AccountId;
        mem2.Program__c = prog2.Id;
        mem2.Name = 'test';
        mem2.Active_Contract_Idenfied__c = testContract2.Id;
        mem2.Latest_Contract__c = testContract2.Id;
        memberships.add(mem2);
        insert memberships;
        
        // CR-20211012-15511 - start
        //create membership key contacts
        list<Membership_Key_Contact__c> keyCons = new list<Membership_Key_Contact__c>();
        Membership_Key_Contact__c kc1 = new Membership_Key_Contact__c(Contact__c = con.Id,
                                                                     Membership__c = mem1.Id,
                                                                     Pubs__c = true);
        keyCons.add(kc1);
        
        Membership_Key_Contact__c kc2 = new Membership_Key_Contact__c(Contact__c = con.Id,
                                                                     Membership__c = mem1.Id,
                                                                     Pubs__c = true);
        keyCons.add(kc2);
        
        Util.BypassAllTriggers = true;
        insert keyCons;
        // CR-20211012-15511 - End
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // new subscription option
        /*List<Subscription_Option__c> subOptions = new List<Subscription_Option__c>();
        Subscription_Option__c subOption = new Subscription_Option__c();
        subOption.Subscription_Status__c = 'Active';
        subOption.Subscription_Category__c = 'EMAIL_DAILY';
        subOption.Name = 'Daily Briefing';
        subOptions.add(subOption);
        Subscription_Option__c subOption2 = new Subscription_Option__c();
        subOption2.Subscription_Status__c = 'Active';
        subOption2.Subscription_Category__c = 'EMAIL_DAILY';
        subOption2.Name = 'Nursing';
        subOptions.add(subOption2);
       
        Util.BypassAllTriggers = false;
        
        insert subOptions;
        
        // 2 new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubOptions = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub1 = new Eligible_Subscription_Option__c();
        eligibleSub1.Program__c = prog1.Id;
        eligibleSub1.Related_Subscription__c = subOption.Id;
        eligibleSubOptions.add(eligibleSub1);
        Eligible_Subscription_Option__c eligibleSub2 = new Eligible_Subscription_Option__c();
        eligibleSub2.Program__c = prog2.Id;
        eligibleSub2.Related_Subscription__c = subOption.Id;
        eligibleSubOptions.add(eligibleSub2);
        Eligible_Subscription_Option__c eligibleSub3 = new Eligible_Subscription_Option__c();
        eligibleSub3.Program__c = prog1.Id;
        eligibleSub3.Related_Subscription__c = subOption2.Id;
        eligibleSubOptions.add(eligibleSub3);
        insert eligibleSubOptions;*/
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // create 1 subscription record for contact1
        /*List<Subscription__c> subs = new List<Subscription__c>();
        Subscription__c sub = new Subscription__c();
        sub.Contact__c = advUserContact1.Id;
        sub.Activation_Date__c = system.today();
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //sub.Subscription_ID__c = eligibleSub1.Id;
        subs.add(sub);
        Subscription__c sub2 = new Subscription__c();
        sub2.Contact__c = advUserContact1.Id;
        sub2.Activation_Date__c = system.today();
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        //sub2.Subscription_ID__c = eligibleSub3.Id;
        subs.add(sub2);
        insert subs;
        
        // get this newly created subscription
        List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id];
        system.assertEquals(2, activeSubscriptions.size());*/
        
        Util.BypassAllTriggers = false;
        // change the end date on the active contract to YESTERDAY
        testContract1.End__c = system.today().addDays(-1);
        update testContract1;
        
        Batch_MembershipSubscriptions batch = new Batch_MembershipSubscriptions();
        //Modify by - Abhinav Sharma - 10/30/2015 - CR-20140407-4977 - Modified to include "Membership_Status__c" field in the query literal
        String theQuery = 'SELECT Id, Account_Name__c, Program__c, Membership_Status__c FROM Membership__c ';
            theQuery += 'WHERE Membership_Status_Change_Date__c = TODAY '; // check for TODAY instead of YESTERDAY
            theQuery += 'AND (NOT Membership_Status__c LIKE \'Member%\') '; // just in case we have a membership that is honorary or grace status
            theQuery += 'ORDER BY createddate desc';
        batch.Query = theQuery;
        // now run the batch job
        database.executeBatch(batch, 50);
        
        test.stopTest();
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // make sure there is still 1 active subscription for this program
        //List<Subscription__c> activeSubscriptions2 = [SELECT Id, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id AND Termination_Date__c = null];
        //system.assertEquals(1, activeSubscriptions2.size());
        //system.assertEquals(prog2.Id, activeSubscriptions2[0].Subscription_Id__r.Program__c);
        
        // make sure there is 1 terminated subscription
        //List<Subscription__c> terminatedSubscription = [SELECT Id, Subscription_Status__c, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id AND Termination_Date__c != null];
        //system.assertEquals(true, terminatedSubscription[0].Subscription_Status__c.contains('Inactive - No Eligible Memberships - '));
        //system.assertEquals(1, terminatedSubscription.size());
    }
    
    /**
     * 
     * @description: test the bulk load process and verify no soql limit is hit.
     * 
     **/
    /*static testMethod void testBatchMembershipSubscription_BulkLoad() {
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        // create 2 contacts on the same account that are also Adv.com Users
        List<Contact> contactList = new List<Contact>();
        List<Contact> conListX = new List<Contact>();
        Contact advUserContact1 = TestUtilities.CreateAdvUserContact(false);
        advUserContact1.LastName = 'contact1';
        contactList.add(advUserContact1);
        Contact advUserContact2 = TestUtilities.CreateAdvUserContact(new Account(Id=advUserContact1.AccountId), false);
        advUserContact2.LastName = 'contact2';
        contactList.add(advUserContact2);
        
        integer numRecords = 20;
        //create # more contacts
        for (integer i = 0; i<numRecords; i++) {
            Util.BypassAllTriggers = true;
            Contact c = TestUtilities.CreateAdvUserContact(false);
            advUserContact2.LastName = 'contactX-'+i;
            conListX.add(c);
        }
        contactList.addAll(conListX);
        insert contactList;
        
        // create 2 programs
        List<Program__c> progList = new List<Program__c>();
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        prog1.Program_Acronym__c = 'HCAB';
        progList.add(prog1);
        Program__c prog2 = TestUtilities.CreateNewProgram(false);
        prog2.Program_Acronym__c = 'NEC';
        progList.add(prog2);
        insert progList;
        
        // create 2 opportunities
        List<Opportunity> opps = new List<Opportunity>();
        List<Contract__c> contracts = new List<Contract__c>();
        Opportunity opp1 = testUtilities.CreateNewOpportunity(advUserContact1.AccountId, false);
        opp1.CloseDate = system.today();
        opp1.stageName = 'Closed Won';
        opp1.Program__c = prog1.Id;
        opps.add(opp1);
        Opportunity opp2 = testUtilities.CreateNewOpportunity(advUserContact1.AccountId, false);
        opp2.CloseDate = system.today();
        opp2.stageName = 'Closed Won';
        opp2.Program__c = prog2.Id;
        opps.add(opp2);
        insert opps;
        
        // create 2 contracts
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = advUserContact1.AccountId, Program__c = prog1.Id, Source_Opportunity__c=opp1.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp1.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        contracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = advUserContact2.AccountId, Program__c = prog2.Id, Source_Opportunity__c=opp2.Id,
            Start__c = System.Today().addDays(-100), End__c = system.today().addDays(2),
            Contract_Renewal_Opportunity__c = opp2.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        contracts.add(testContract2);
        test.startTest();
        insert contracts;
        Util.BypassAllTriggers = false;
        
        // create 2 memberships
        List<Membership__c> memberships = new List<Membership__c>();
        Membership__c mem1 = new Membership__c();
        mem1.Membership_Status_Text__c = 'Member - Payer';
        mem1.Account_Name__c = advUserContact1.AccountId;
        mem1.Program__c = prog1.Id;
        mem1.Name = 'test';
        mem1.Active_Contract_Idenfied__c = testContract1.Id;
        mem1.Latest_Contract__c = testContract1.Id;
        memberships.add(mem1);
        Membership__c mem2 = new Membership__c();
        mem2.Membership_Status_Text__c = 'Member - Payer';
        mem2.Account_Name__c = advUserContact2.AccountId;
        mem2.Program__c = prog2.Id;
        mem2.Name = 'test';
        mem2.Active_Contract_Idenfied__c = testContract2.Id;
        mem2.Latest_Contract__c = testContract2.Id;
        memberships.add(mem2);
        
        for (Contact c : conListX) {
            Membership__c memx = new Membership__c(Membership_Status_Text__c = 'Inactive',
                                                  Account_Name__c = advUserContact1.AccountId,
                                                  Program__c = prog1.Id,
                                                  Name = 'test',
                                                  Active_Contract_Idenfied__c = testContract1.Id,
                                                  Latest_Contract__c = testContract1.Id);
            memberships.add(memx);
        }
        
        insert memberships;
        
        // new subscription option
        List<Subscription_Option__c> subOptions = new List<Subscription_Option__c>();
        Subscription_Option__c subOption = new Subscription_Option__c();
        subOption.Subscription_Status__c = 'Active';
        subOption.Subscription_Category__c = 'EMAIL_DAILY';
        subOption.Name = 'Daily Briefing';
        subOptions.add(subOption);
        Subscription_Option__c subOption2 = new Subscription_Option__c();
        subOption2.Subscription_Status__c = 'Active';
        subOption2.Subscription_Category__c = 'EMAIL_DAILY';
        subOption2.Name = 'Nursing';
        subOptions.add(subOption2);
        insert subOptions;
        
        // 2 new eligible subscription option
        List<Eligible_Subscription_Option__c> eligibleSubOptions = new List<Eligible_Subscription_Option__c>();
        Eligible_Subscription_Option__c eligibleSub1 = new Eligible_Subscription_Option__c();
        eligibleSub1.Program__c = prog1.Id;
        eligibleSub1.Related_Subscription__c = subOption.Id;
        eligibleSubOptions.add(eligibleSub1);
        Eligible_Subscription_Option__c eligibleSub2 = new Eligible_Subscription_Option__c();
        eligibleSub2.Program__c = prog2.Id;
        eligibleSub2.Related_Subscription__c = subOption.Id;
        eligibleSubOptions.add(eligibleSub2);
        Eligible_Subscription_Option__c eligibleSub3 = new Eligible_Subscription_Option__c();
        eligibleSub3.Program__c = prog1.Id;
        eligibleSub3.Related_Subscription__c = subOption2.Id;
        eligibleSubOptions.add(eligibleSub3);
        insert eligibleSubOptions;
        
        // create 1 subscription record for contact1
        List<Subscription__c> subs = new List<Subscription__c>();
        Subscription__c sub = new Subscription__c();
        sub.Contact__c = advUserContact1.Id;
        sub.Activation_Date__c = system.today();
        sub.Subscription_ID__c = eligibleSub1.Id;
        subs.add(sub);
        Subscription__c sub2 = new Subscription__c();
        sub2.Contact__c = advUserContact1.Id;
        sub2.Activation_Date__c = system.today();
        sub2.Subscription_ID__c = eligibleSub3.Id;
        subs.add(sub2);
        
        for (Contact c : conListX) {
            Subscription__c subx = new Subscription__c();
            subx.Contact__c = c.Id;
            subx.Activation_Date__c = system.today();
            subx.Subscription_ID__c = eligibleSub1.Id;
            subs.add(subx);
        }
        
        insert subs;
        
        // get this newly created subscription
        List<Subscription__c> activeSubscriptions = [SELECT Id, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id];
        system.assertEquals(2, activeSubscriptions.size());
        
        //create membership key contacts
        list<Membership_Key_Contact__c> keyCons = new list<Membership_Key_Contact__c>();
        Membership_Key_Contact__c kc1 = new Membership_Key_Contact__c(Contact__c = advUserContact1.Id,
                                                                     Membership__c = mem1.Id,
                                                                     Pubs__c = true);
        keyCons.add(kc1);
        
        Membership_Key_Contact__c kc2 = new Membership_Key_Contact__c(Contact__c = advUserContact2.Id,
                                                                     Membership__c = mem1.Id,
                                                                     Pubs__c = true);
        keyCons.add(kc2);
        
        for (Contact c : contactList) {
            Membership_Key_Contact__c kc = new Membership_Key_Contact__c(Contact__c = c.Id,
                                                                        Membership__c = mem1.Id,
                                                                        Pubs__c = true);
            keyCons.add(kc);
        }
        
        Util.BypassAllTriggers = true;
        insert keyCons;
        
        
        Util.BypassAllTriggers = false;
        // change the end date on the active contract to YESTERDAY
        testContract1.End__c = system.today().addDays(-1);
        update testContract1;
        
        Batch_MembershipSubscriptions batch = new Batch_MembershipSubscriptions();
        //Modify by - Abhinav Sharma - 10/30/2015 - CR-20140407-4977 - Modified to include "Membership_Status__c" field in the query literal
        String theQuery = 'SELECT Id, Account_Name__c, Program__c, Membership_Status__c FROM Membership__c ';
            theQuery += 'WHERE Membership_Status_Change_Date__c = TODAY '; // check for TODAY instead of YESTERDAY
            theQuery += 'AND (NOT Membership_Status__c LIKE \'Member%\') '; // just in case we have a membership that is honorary or grace status
            theQuery += 'ORDER BY createddate desc';
        batch.Query = theQuery;
        // now run the batch job
        database.executeBatch(batch, 50);
        
        test.stopTest(); 
        
        // make sure there is still 1 active subscription for this program
        List<Subscription__c> activeSubscriptions2 = [SELECT Id, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id AND Termination_Date__c = null];
        system.assertEquals(1, activeSubscriptions2.size());
        system.assertEquals(prog2.Id, activeSubscriptions2[0].Subscription_Id__r.Program__c);
        
        // make sure there is 1 terminated subscription
        List<Subscription__c> terminatedSubscription = [SELECT Id, Subscription_Status__c, Subscription_Id__r.Program__c FROM Subscription__c WHERE Contact__c = :advUserContact1.Id AND Termination_Date__c != null];
        system.assertEquals(true, terminatedSubscription[0].Subscription_Status__c.contains('Inactive - No Eligible Memberships - '));
        system.assertEquals(1, terminatedSubscription.size());
    }*/
}