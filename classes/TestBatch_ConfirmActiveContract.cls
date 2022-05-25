/*
    Purpose		:    Test Class Batch_ConfirmActiveContract
    
    Create By		:    Pierre Eymard
    
    Last Modified By	:    Nathan Banas (SAP) - 1/26/2011
    
    Current Version	:    
    
    Revision Log	:    V1.0 - (NB) Created code
    			     V1.1 - Modified By - (NB-2011-01-26) Added header, code comments, and reviewed code coverage
    			     V1.2 - Modified By - (SUNJ 12/19/13) - CR-20130118-2218
    			     V1.3 - Modified By - Ajit Surana - 11/13/2014 - Class code modified to remove apex errors occuring during Release 38 deployment
    			     V1.4 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    
    Code Coverage as of 1/26/2011: 98%
*/
@isTest(seeAllData=false)
private class TestBatch_ConfirmActiveContract
{
      
    
    /**
     * @Description: Verify that the job is executing as intended, and updating the corresponding Membership
     * 
     * @Revisions: Victor Hanson - 1/9/2017 - Created - CR-20180109-11882
     **/
    static testMethod void testUpdateMemberships() {
        
        Util.BypassAllTriggers = true;
        
        Program__c prog = TestUtilities.CreateNewProgram(null, 'test', 'No', null, true);
        Account acct = TestUtilities.CreateNewAccount('US Corporate', true);
        
        Contract__c con = TestUtilities.CreateNewContract(false);
        con.Status__c = 'Dropped';
        con.Payer_Account__c = acct.Id;
        con.Program__c = prog.Id;
        con.Start__c = system.today().addDays(-100);
        con.End__c = system.today().addDays(-2);
        
        insert con;
        
        Membership__c m = new Membership__c(Latest_Contract__c = con.Id,
                                        Program__c = prog.Id,
                                        Account_Name__c = acct.Id,
                                        Membership_Status_Text__c = 'Member - Payer');
        insert m;
        
        test.startTest();
        
        util.BypassAlltriggers = false;
        
        //execute the batch
        Database.executeBatch(new Batch_ConfirmActiveContract(), 1);
        
        test.stopTest();
        
        //get the updated membership
        m = [SELECT Id, Membership_Status_Text__c FROM Membership__c WHERE Id = :m.Id];
        
        //assertions
        //system.assertEquals(Constants.PROSPECT_PAST_MEMBER, m.Membership_Status_Text__c);
    }
    
    static testmethod void testActiveField() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Make sure Contract Active field is being set properly 
        
        //set flags
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;
        
        //list is false when it should be true
        list<Contract__c> falsecons = new List<Contract__c>();
        for (integer i = 0; i < 4; i++) {
            Contract__c con = TestUtilities.CreateNewContract(false);
            con.Status__c = 'Pending';
            falsecons.add(con);
        }
        insert falsecons;
        
        for (Contract__c newc : falsecons) {
            newc.Active__c = false;
            newc.Start__c = system.today();
            newc.End__c = system.today().addDays(365);
        }
        
        //list is true when it should be false
        list<Contract__c> truecons = new List<Contract__c>();
        for (integer i = 0; i < 4; i++) {
            Contract__c con = TestUtilities.CreateNewContract(false);
            con.Status__c = 'Pending';
            truecons.add(con);
        }
        insert truecons;
        
        /*list<Contract__c> truecons = [select id, Start__c, Active__c, End__c from Contract__c 
where Status__c != 'ATL' 
and Status__c != 'Honorary' 
and id not in :falsecons
limit 5];*/
        
        for (Contract__c newc : truecons) {
            newc.Active__c = true;
            newc.Start__c = system.today().addDays(-365);
            newc.End__c = system.today().addDays(-1);
        }
        
        list<Contract__c> cons = new list<Contract__c>();
        cons.addall(falsecons);
        cons.addall(truecons);
        update cons;
        
        cons = [select id, Start__c, Active__c, End__c from Contract__c 
                where id in :cons];
        set<Id> conids = new set<Id>();
        String querystring = 'select id , Start__c, End__c, Program__c, Payer_Account__c, Active__c, CreatedDate from Contract__c'
            + ' where id in (';
        Boolean firstField = true;
        for (Contract__c c : cons) {
            if (FirstField) {
                FirstField = false;
            } else {
                querystring += ', ';
            }
            
            querystring += '\'' + c.id + '\'';
            conids.add(c.id);
            if (c.Start__c == system.today()) 
                system.assertEquals(false, c.Active__c);
            else
                system.assertEquals(true, c.Active__c);
        }
        querystring += ')';
        test.StartTest();      
        Util.byPassAllTriggers = false; 
        Batch_ConfirmActiveContract batch = new Batch_ConfirmActiveContract();
        batch.query = querystring;
        system.debug('\n\n 51 batch \ncontracts ' + conids);    
        Database.executeBatch(batch,50);
        test.StopTest();
        cons = [select id, CreatedDate, LastModifiedDate, Start__c, Active__c, End__c from Contract__c 
                where id in :cons];
        //verify Active field is flipped for all records
        for (Contract__c c : cons) {
            //system.assert(c.LastModifiedDate > c.CreatedDate);
            if (c.Start__c == system.today()) 
                system.assertEquals(true, c.Active__c);
            else
                system.assertEquals(false, c.Active__c);
        }
    }
    
    static testmethod void testMembershipFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*  Make sure Membership fields are being set properly */
        //set flags to keep triggers out of the way
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;
        
        list<Account> testaccs = new list<Account>();
        Account a1 = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc1');
        testaccs.add(a1);
        Account a2 = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc2');
        testaccs.add(a2);
        Account a3 = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc3');
        testaccs.add(a3);
        insert testaccs;
        
        Contact c = new Contact(LastName = 'test', AccountID = a1.id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert c;
        
        Program__c prog = new Program__c(Name = 'testprog');
        insert prog;
        
        list<Membership__c> mems = new list<Membership__c>();
        mems.add(new Membership__c(
            Account_Name__c = a1.id,
            Program__c = prog.id,
            Name = 'testmem'
        ));
        mems.add( new Membership__c(
            Account_Name__c = a2.id,
            Program__c = prog.id,
            Name = 'testmem'
        ));
        mems.add( new Membership__c(
            Account_Name__c = a3.id,
            Program__c = prog.id,
            Name = 'testmem'
        ));
        insert mems;
        
        list<Contract__c> contracts = new list<Contract__c>();
        
        //Negotiated Amount, Type, Start, End, Year, Program, Join Date, Payer Account, Main Contact, and Invoice Contact
        //three contracts, one for each Account     
        contracts.add(new Contract__c(
            Payer_Account__c = a1.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
        ));
        contracts.add(new Contract__c(
            Payer_Account__c = a2.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-10),
            End__c = system.today().addDays(355),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100
        ));
        contracts.add(new Contract__c(
            Payer_Account__c = a3.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(1000),
            End__c = system.today().addDays(1005),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
        ));
        contracts.add(new Contract__c(
            Payer_Account__c = a3.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(900),
            End__c = system.today().addDays(999),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
        ));
        system.debug('\n\n151 insert');     
        insert contracts;
        
        //a Contract Integrated Account, on Contract with A1, but the CIA has Account__c = A2 
        //(This will link the A1 Contract to the A2 Membership.)
        contracts = [select Active__c, Start__c, Payer_Account__c from Contract__c where id in :contracts];
        for (Contract__c con : contracts) {
            if (con.Payer_Account__c == a1.id) {
                Contract_Integrated_Accounts__c testcia1 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a2.id);
                
                Contract_Integrated_Accounts__c testcia2 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a2.id);
                
                insert testcia1;
                insert testcia2;
            }
            
            //asserts
            if (con != null && con.Start__c > system.today()) {
                system.assertEquals(true, con.Active__c);
            }
        }
        
        //Create query string to test batch on these contracts
        String querystring = 'select id , start__c, end__c, Program__c, Payer_Account__c, lastmodifieddate, active__c from Contract__c'
            + ' where id in (';
        Boolean FirstField = true;
        for (Contract__c con : contracts) {
            if (FirstField) {
                FirstField = false;
            } else {
                querystring += ', ';
            }
            querystring += '\'' + con.id + '\'';
        }
        querystring += ')';
        system.debug('\n\n136 testing query ' + querystring);       
        
        mems = [select Account_Name__c, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c 
                from Membership__c where id in :mems];
        for (Membership__c mem : mems) {
            system.assertEquals(null, mem.Active_Contract_Idenfied__c);
            system.assertEquals(null, mem.Earliest_Contract__c);
            system.assertEquals(null, mem.Latest_Contract__c);
        }
        test.StartTest();
        Util.byPassAllTriggers = false;
        Batch_ConfirmActiveContract bcac = new Batch_ConfirmActiveContract();
        bcac.query = querystring;
        Database.executeBatch(bcac, 50);
        system.debug('\n\n150 stoptest');       
        
        test.StopTest();        
        
        //Verify we set all the Membership fields correctly.
        mems = [select Account_Name__c, Active_Contract_Idenfied__c, Active_Contract_Idenfied__r.Start__c, 
                Earliest_Contract__c, Earliest_Contract__r.Start__c,
                Latest_Contract__c, Latest_Contract__r.End__c
                from Membership__c where id in :mems];
    }
    
    //Modified by - Ajit Surana - 11/13/2014
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testUpdateMembershipOwnerFromOpps()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        
        // get an active user to test with
        User newUsr = [SELECT Name, Id, Email FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator'AND ManagerId != null LIMIT 1];
        
                
        //set flags to keep triggers out of the way
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        list<Account> testaccs = new list<Account>();
        Account a1 = TestUtilities.CreateNewAccount(false);
        testaccs.add(a1);
        Account a2 = TestUtilities.CreateNewAccount(false);
        testaccs.add(a2);
        insert testaccs;
        
        Contact c = TestUtilities.CreateNewContact(a1, true);
        
        Program__c prog = TestUtilities.CreatenewProgram(true);
        
        list<Contract__c> contracts = new list<Contract__c>();
        
        //Negotiated Amount, Type, Start, End, Year, Program, Join Date, Payer Account, Main Contact, and Invoice Contact
        //three contracts, one for each Account     
        contracts.add(new Contract__c(
            Payer_Account__c = a1.id,
            Program__c = prog.id,
            Status__c = 'Integrated',
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
        ));
        insert contracts;
        
        // insert memberships that are associated with our contract
        list<Membership__c> mems = new list<Membership__c>();
        mems.add(TestUtilities.CreateNewMembership(a1.Id, prog.Id, false));
        mems.add(TestUtilities.CreateNewMembership(a1.Id, prog.Id, false));
        for (Membership__c m : mems) {
            m.Active_Contract_Idenfied__c = contracts[0].id;
            m.Membership_Status_Text__c = 'prospect';
            m.Latest_Contract__c = contracts[0].id;
            m.Earliest_Contract__c = contracts[0].id;
        }
        insert mems;
        
        // get opportunity record type id: RI AM Standard Opp
        Id recordTypeid = TestUtilities.FindRecordTypeId('Opportunity', 'RI AM Standard Opp');
        // create the opportunity with membership
        Opportunity opp = new Opportunity();
        opp.name = 'testopp1';
        opp.AccountId = a1.Id;
        opp.Main_Contact__c = c.Id;
        opp.Membership__c = mems[0].Id;
        opp.StageName = 'Pending';
        opp.Amount = 1000;
        opp.CloseDate = system.today().addDays(32);
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp.Sales_Pursuit_Products__c  = 'APS';
        opp.Type = 'Contract Renewal Opportunity';
        insert opp;
        
        // get our contract again so that we can push the opportunity id in the Contract_Renewal_Opportunity__c field
        contracts = [SELECT Name, Id, Contract_Renewal_Opportunity__c FROM Contract__c WHERE id in :contracts];
        contracts[0].Contract_Renewal_Opportunity__c = opp.Id;
        update contracts;
        
        mems = [select OwnerId, Account_Name__c, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c 
                from Membership__c where id in :mems];
        for (Membership__c mem : mems) {
            system.assertEquals(contracts[0].id, mem.Active_Contract_Idenfied__c);
            system.assertEquals(contracts[0].id, mem.Earliest_Contract__c);
            system.assertEquals(contracts[0].id, mem.Latest_Contract__c);
            system.assertEquals(mem.OwnerId, userinfo.getUserId());
        }
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(opp.Id);
        test.StartTest();   
        Util.byPassAllTriggers = false;
        // update the Opportunity's Owner
        opp.OwnerId = newUsr.Id;
        update opp;
        // run the proceedure to update the membership owners!
        Util.membershipOwnerCheckfromOpps(oppIds);
        test.StopTest();        
        
        //Verify we set all the Membership fields correctly.
        mems = [select Account_Name__c, OwnerId, Membership_Status__c, Active_Contract_Idenfied__c, Active_Contract_Idenfied__r.Start__c, 
                Earliest_Contract__c, Earliest_Contract__r.Start__c,
                Latest_Contract__c, Latest_Contract__r.End__c
                from Membership__c where id in :mems];
        
        for (Membership__c mem : mems) {
            if (mem.Account_Name__c == a1.id) { //should only have the A1 contract and have a new owner!
                system.assertEquals(system.today().addDays(-100), mem.Active_Contract_Idenfied__r.Start__c);
                system.assertEquals(system.today().addDays(-100), mem.Earliest_Contract__r.Start__c);
                system.assertEquals(system.today().addDays(265), mem.Latest_Contract__r.End__c);
                // this is really what we are testing -- make sure the owner is updated
                system.assertEquals(newUsr.Id, mem.OwnerId);
            } else if (mem.Account_Name__c == a2.id) { // should only have the A1 contract and have a new owner!
                system.assertEquals(system.today().addDays(-100), mem.Active_Contract_Idenfied__r.Start__c);
                system.assertEquals(system.today().addDays(-100), mem.Earliest_Contract__r.Start__c);
                system.assertEquals(system.today().addDays(265), mem.Latest_Contract__r.End__c);
                // this is really what we are testing -- make sure the owner is updated
                system.assertEquals(newUsr.Id, mem.OwnerId);
            }
        }
    }
}