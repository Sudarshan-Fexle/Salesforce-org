/*
    Purpose:   Test class for Batch_MonitorATMs 
    
    Create By:          Pratik
    
    Last Modified By:   Pratik 8/05/11
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 -  Created code
                        v1.1 - Code modified - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
                        v2.0 - Code modified - Victor Hanson - 06/20/2013 - CR-20130501-2958
                        v2.1 - Code modified - Jeffery Sun - 12/19/2013 - CR-20130118-2218
                        v2.2 - Code modified - Deepak Kumar - 07/03/2017 - Q2C
                        v2.3 - Code modified - Dipesh Gupta - 09/07/2017 - CR-20170519-10947
             		v2.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    */
@istest
class Test_Batch_MonitorATMs 
{
    
    static testmethod void test() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Profile> profiles = [select id from Profile WHERE Name = 'System Administrator'];
        System.assert(profiles != null);
        
        list<User> users = new list<User>();
        
        for (Integer i = 0; i < 8; i++) {
            
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8',
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US',
                profileid = profiles[0].id, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser1971' + digit + '@advisory.com'
                ));
        }
        insert users;
        
        list<Account> Accounts = new list<Account>();
        
        Account acc1 = new Account(Name = 'TestAccount', Account_Formal_Name__c = 'formaltest',Advisory_com_Organization_Status__c = 'Active');
        Accounts.add(acc1);
        
        Account acc2 = new Account(Name = 'TestAccount2', Account_Formal_Name__c = 'formaltest2', Advisory_com_Organization_Status__c = 'Active');
        Accounts.add(acc2);
        
        //v2.3 - Code modified - Dipesh Gupta - 09/07/2017 - CR-20170519-10947
        Account acc3 = new Account(Name = 'TestAccount3', Account_Formal_Name__c = 'formaltest3', Advisory_com_Organization_Status__c = 'Active');
        Accounts.add(acc3);
        
        Account acc4 = new Account(Name = 'TestAccount4', Account_Formal_Name__c = 'formaltest4', Advisory_com_Organization_Status__c = 'Active');
        Accounts.add(acc4);
        
        insert Accounts;       
        
        for (Account acc:Accounts) 
        {
            acc.Historical_Linker__c = null;
        }
        update Accounts;
        
        list<Program__c> progs = new list<Program__c>();
        
        Program__c prog = new Program__c(
                                Name = 'prog', 
                                Program_Acronym__c = 'TESTPROG', 
                                New_Business_Marketer__c = 'test Marketer'         
                                );
        progs.add(prog);
        
        Program__c prog1 = new Program__c(
                                Name = 'prog1', 
                                Program_Acronym__c = 'TESTPROG1', 
                                New_Business_Marketer__c = 'PT - Marketer'         
                                );
        progs.add(prog1);
        
        insert progs;
        
        list<Contact> cons = new list<Contact>();
        
        Contact con1 = new Contact(AccountId = acc1.id,
                                LastName = 'testlast1',
                                Email = 'Test'+Math.random()+'@eab.com', 
                                Title = 'Test', 
                                Phone = '614-555-8855'
                                );
        cons.add(con1);
        
        Contact con2 = new Contact(AccountId = acc1.id,
                                LastName = 'testlast2',
                                Email = 'Test'+Math.random()+'@eab.com', 
                                Title = 'Test', 
                                Phone = '614-555-8855'
                                );
        cons.add(con2);
        
        Contact con3 = new Contact(AccountId = acc1.id,
                                LastName = 'testlast3',
                                Email = 'Test'+Math.random()+'@eab.com', 
                                Title = 'Test', 
                                Phone = '614-555-8855'
                                );
        cons.add(con3);
        
        //This is going to be the EA Contact
        Contact con4 = new Contact(AccountId = acc1.id,
                                LastName = 'testlast4', 
                                Employee_User_Record__c = users[2].Id,
                                Email = 'Test'+Math.random()+'@eab.com', 
                                Title = 'Test', 
                                Phone = '614-555-8855'
                                );
        cons.add(con4);
        
        Contact con5 = new Contact(AccountId = acc1.id, LastName = 'testlast5',Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855' );
        cons.add(con5);
        
        insert cons;
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c1 = new Contract__c(
                                Start__c = system.today().addDays(-100),
                                End__c = system.today().addDays(-50),
                                Program__c = prog.id,
                                Name = 'TestContract',
                                Payer_Account__c = acc1.Id
                                );
        contracts.add(c1);
        
        Contract__c c2 = new Contract__c(
                                Start__c = system.today().addDays(-10),
                                End__c = system.today().addDays(50),
                                Program__c = prog.id,
                                Name = 'TestContract2',
                                Payer_Account__c = acc1.Id
                                );
        contracts.add(c2);
        
        Contract__c c3 = new Contract__c(
                                Start__c = system.today().addDays(-100),
                                End__c = system.today().addDays(-50),
                                Program__c = prog1.id,
                                Name = 'TestContract3',
                                Payer_Account__c = acc1.Id
                                );
        contracts.add(c3);
        
        insert contracts;
        
        //Test code for Batch_MonitorATMs
        Test.StartTest();
        
        Membership__c mem = new Membership__c(
                                    Name= 'Test Membership',
                                    Program__c = prog.id,
                                    Account_Name__c = acc1.id, 
                                    Earliest_Contract__c = c1.id,
                                    Active_Contract_Idenfied__c = c2.id,
                                    Membership_Status_Text__c = 'Prospect Testing'
                                    );
        
        list<Membership__c> mems = new list<Membership__c>{mem};
        insert mems;
        
        mem = [select Earliest_Contract__c, Active_Contract_Idenfied__c from Membership__c where Id = :mem.id];
        
        system.assertEquals(c1.Id, mem.Earliest_Contract__c);
        system.assertEquals(c2.Id, mem.Active_Contract_Idenfied__c);
        
        List<Opportunity> opps = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity o1 = new Opportunity(
                                AccountId = acc1.Id, 
                                StageName = '0-Exploring',
                                Chairman_s_Team_Rep__c = users[0].Id, 
                                Main_Contact__c = con1.Id,  
                                Signed_Opportunity_Contract__c = c1.Id, 
                                Start__c = system.today().addDays(-1),
                                CloseDate = system.today().addDays(31), 
                                Name = 'TestOpp',  
                                Amount = 1,Sales_Pursuit_Products__c = 'APS',
                                OwnerId = users[5].Id
                                );
        opps.add(o1);
        
        Opportunity o2 = new Opportunity(
                                AccountId = acc1.Id, 
                                StageName = '0-Exploring',  
                                Chairman_s_Team_Rep__c = users[1].Id,
                                Main_Contact__c = con2.Id,
                                Signed_Opportunity_Contract__c = c2.Id,
                                Start__c = system.today().addDays(-1),    
                                CloseDate = system.today().addDays(31),Name = 'TestOpp', Sales_Pursuit_Products__c = 'APS',
                                Amount = 1
                                );
        opps.add(o2);
        
        insert opps;
        
        c2.Contract_Renewal_Opportunity__c = o1.Id;
        update c2;
        
        Membership__c mem3 = new Membership__c(
                                        Name= 'Test Membership3',
                                        Program__c = prog.id,
                                        Account_Name__c = acc1.id, 
                                        Earliest_Contract__c = c1.id,
                                        Active_Contract_Idenfied__c = c2.id,
                                        Membership_Status_Text__c = 'Prospect Testing'
                                        );
        Membership__c mem2 = new Membership__c(
                                        Name= 'Test Membership2',
                                        Program__c = prog1.id,
                                        Account_Name__c = acc1.id, 
                                        Earliest_Contract__c = c1.id,
                                        Membership_Status_Text__c = 'Prospect Testing'
                                        );
        mems = new list<Membership__c>{mem2, mem3};
        insert mems;
        
        mem3 = [select Assigned_Marketer__c from Membership__c where Id = :mem3.Id];
        system.assertEquals(null, mem3.Assigned_Marketer__c);
        
        AccountTeamMember atm1 = new AccountTeamMember(
                                        AccountId = acc1.Id,
                                        UserId = users[2].Id,
                                        TeamMemberRole = 'Membership Advisor (NASA)'
                                        );
                                        
        AccountTeamMember atm2 = new AccountTeamMember(
                                        AccountId = acc1.Id,
                                        UserId = users[1].Id,
                                        TeamMemberRole = 'PT - Marketer'
                                        );
                                        
        AccountTeamMember atm3 = new AccountTeamMember(
                                        AccountId = acc1.Id,
                                        UserId = users[3].Id,
                                        TeamMemberRole = 'test Marketer'
                                        );
        
        // This will be our RM RI User
        AccountTeamMember atm4 = new AccountTeamMember(
                                        AccountId = acc1.Id,
                                        UserId = users[4].Id,
                                        TeamMemberRole = 'Research & Insights RM'
                                        );
        AccountTeamMember atm6 = new AccountTeamMember(
                                        AccountId = acc3.Id,
                                        UserId = users[6].Id,
                                        TeamMemberRole = 'Associate Principal (NASA)'
                                        );
                                        
        AccountTeamMember atm7 = new AccountTeamMember(
                                        AccountId = acc4.Id,
                                        UserId = users[7].Id,
                                        TeamMemberRole = 'Principal (NASA)'
                                        );
                                        
        List<AccountTeamMember> ATMs = new List<AccountTeamMember>{ atm1, atm2, atm3, atm4, atm6, atm7};
        Database.SaveResult[]  lsr = Database.Insert(ATMs);
        
        Util.byPassAllTriggers = false;
        
        System.runAs(users[0]) {
            
            //batch job
            Batch_MonitorATMs Batch_MonitorATMsObj = new Batch_MonitorATMs();
            
            //v2.3 - Code modified - Dipesh Gupta - 09/07/2017 - CR-20170519-10947
            //Code modified by - Bhavi Sharma - 06/17/2013 - CR-20130513-3009
            String atmRoleList = '(' + '\'AE or EA\'' + ',' +  ' \'RI' + ' ' + '-'  + ' ' + 'Executive' + ' ' + 'Advisor\'' +',' +' \'RI' + ' ' + '-'  + ' ' + 'Account ' + 'Exec\'' 
                    + ','+'\'Membership Advisor (NASA)\'' +',' +'\'Associate Principal (NASA)\'' + ',' +  '\'Principal (NASA)\'' + ',' + '\'Research & Insights RM\'' +')';
            
            Batch_MonitorATMsObj.Query = 'Select Id, (Select Id, TeamMemberRole From AccountTeamMembers where (TeamMemberRole IN '+ atmRoleLIst+' or TeamMemberRole like \'%Marketer\')'
                                            + ' and lastModifiedDate = LAST_N_DAYS:3) From Account Where Id = \'' + acc1.Id + '\' or Id = \'' + acc2.Id + '\' or Id = \'' + acc3.Id + '\'or Id = \'' + acc4.Id + '\' Limit 200';
            
            Batch_MonitorATMsObj.debugLogStr = 'Error message';
            ID batchprocessid1 = Database.executeBatch(Batch_MonitorATMsObj);
                    
        }

        //Test will stop here
        Test.StopTest(); 
       
        // Check if account's EA_AE equals ATM's user Id 
        List<Account> account1 = [select EA_AE__c from Account order by Name];
        
        //v2.3 - Code modified - Dipesh Gupta - 09/07/2017 - CR-20170519-10947
        system.assertEquals(4,accounts.Size());
        system.assertEquals(atm1.UserId, account1[0].EA_AE__c);
        system.assertEquals(atm6.UserId, account1[2].EA_AE__c);
        system.assertEquals(atm7.UserId, account1[3].EA_AE__c);
        
        // Check if Membership's equals membership's Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId they should be equal
        mem3 = [select OwnerId, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId, Assigned_Marketer__c
                        from Membership__c where Id = :mem3.Id];
        
        mem2 = [select OwnerId, Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId, Assigned_Marketer__c
            from Membership__c
            where Id = :mem2.Id];
        
        //Assigned Marketer
        //System.assertEquals(atm3.UserId, mem3.Assigned_Marketer__c); 
        //system.assertEquals(atm2.UserId, mem2.Assigned_Marketer__c);
        
        //Prospect owner
        //system.assertEquals(mem2.Assigned_Marketer__c, mem2.OwnerId);
        //Non-prospect owner
        //system.assertEquals(mem3.Active_Contract_Idenfied__r.Contract_Renewal_Opportunity__r.OwnerId, mem3.OwnerId);
    }
    
    static testmethod void test_RM_RI()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // create the user, account, and account team member
        User rmRIUser = TestUtilities.CreateNewUser(true);
        Account acct = TestUtilities.CreateNewAccount(true);  
        AccountTeamMember atm = new AccountTeamMember(
                                    AccountId = acct.Id,
                                    UserId = rmRIUser.Id,
                                    TeamMemberRole = 'Research & Insights RM'
                                );
        insert atm;
        
        // begin the test 
        Test.StartTest();
        
        Util.byPassAllTriggers = false;
        // start the batch job
        ID batchprocessid1 = Database.executeBatch(new Batch_MonitorATMs());
        
        // stop the test
        Test.StopTest(); 
    }   
}