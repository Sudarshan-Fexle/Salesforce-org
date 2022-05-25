@istest
private class TestUtil
{
    /*
    Purpose:    Test Class Util
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Jeremy Nottingham (SAP) 5/19/11
    
    Current Version:    v1.2
    
    Revision Log:       V1.0 - (NB) Created code
                        V1.1 - (NB-2011-01-26 thru 2011-01-27) Added header, code comments, and reviewed code coverage
                        V1.2 - (JN 5/19/11) changed testmakememberships to not include deleting active Program records
                             - And added separate support to test resetRecordtypesettings
                        V1.3 - (CR-20130531-3103 - Bhavi Sharma - 07/12/2013) - Test method modified (testmakememberships_v2)
                        V1.4 - (SUNJ 12/19/13) - CR-20130118-2218
                        V1.5 - Modified By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376 - Added a new test method to check functionality of "formatToAlphabatical" method in Util class.
                        V1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Added a new test method to check functionality of "businessHoursForStartAndEndDate" method in Util class.            
                        V1.7 - Modified By - Subhash Garhwal - 02/03/2017 - CR-20160509-9842 - Modified (testresetRecordtypesettings) method
                        V1.8 - Modified By - Mahendra Swarnkar - 10/16/2017 - Apollo Release - Added (testValidateEntityValue1) method
                        V1.9 - Modified By - Rajeev jain - 05/16/2018 - CR-20180329-12133 - Deployemnt Failure.
                        V2.0 - Removed refernce of Program_MTM__c - Spring clean up
                        V2.1 - Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
			V2.2 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 
            		V2.3 - Modified By - Abhinav Sharma - CR-20200318-13867 - 09/04/2020 - Project Page Layout and RT deletions
			V2.4 - Commented By Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756
			V2.5 - Modified By Saurabh Kumar - CR-20200819-14447 - 10/13/2020 - Replaced Meeting with EAB Event
			V2.6 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*/
    
    static testmethod void testutil()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        system.assertEquals(true, Util.IsTesting); 
    }
    
    static testmethod void testrtmap()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        //test recordtypemap() and also resetRecordtypeSettings()
        RecordType testrt = [select Id, Name, SObjectType from Recordtype limit 1];
        map<String, Id> rtmap = Util.recordtypemap(testrt.SObjectType);
        //system.assertEquals(null, rtmap.get(testrt.Name));
        
        test.startTest();
        rtmap = Util.recordtypemap(testrt.SObjectType);
        //system.assertEquals(null, rtmap.get(testrt.Name));
        
        test.stopTest();
    }
    
    //Modified by - Subhash Garhwal - 02/03/2017 - CR-20160509-9842
    static testmethod void testresetRecordtypesettings() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Start from here
        test.startTest();
        
        //Calling Util class method to reset record type setting records
        Util.resetRecordtypeSettings();
        
        //Stop test here
        test.stopTest();
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756 : IRC Request, PT_Support_Request
        //Query case record types
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN (/*'PT_Support_Request', 'IRC_Request',*/ 'International')
                                        ORDER By DeveloperName DESC];
        
        //Asserting for results
        System.assert(caseRdTypes.size() > 0);
        
        //Calling Util class method to reset record type setting records
        Util.resetRecordtypeSettings();
    }
    
static testmethod void membershipOwnerCheckfromMemberships()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //By Pass all the triggers
        Util.BypassAllTriggers = true;
        
        Id prfid = [select id from Profile where Name = 'Marketers' limit 1].id;
        system.assertnotEquals(null, prfid);
        
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prfid, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser' + digit + '@advisory.com',
                IsActive = true
                ));
        }
        insert users;
        User u1 = users[0];
        
        //Contact con1 = [select Id, Name from Contact where Counter_ID__c = :u1.Employee_Contact_RecordID__c limit 1];
        Contact con1 = new Contact(
            LastName = 'testcontact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con1;
        
        Account a = new Account(Name = 'TestAccount', EA_AE__c = u1.Id);
        insert a;
        
        Program__c p = new Program__c(Name='TestProg', Program_Acronym__c = 'ZTP');
        insert p;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = a.Id, StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1), 
                                         CloseDate = system.today().addDays(32), Name = 'TestOpp', Amount = 1);
        opps.add(o1);
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c = new Contract__c(Name = 'TestContract', Payer_Account__c = a.Id, Start__c = system.today().addDays(1), End__c = system.today().addDays(3));
        contracts.add(c);
        Contract__c c1 = new Contract__c(Name = 'TestContract', Status__c = 'Honorary', Payer_Account__c = a.Id,
            Start__c = system.today().addDays(-1), End__c = system.today().addDays(5),
            Negotiated_Amount__c = 1, Type__c = 'Renewal', Year__c = '2011', Program__c = p.Id, Join_Date__c = System.today(),
            Main_Contact__c = con1.Id, Invoice_Contact__c = con1.Id, Contract_Renewal_Opportunity__c = o1.Id);
        contracts.add(c1);
        
        insert contracts;

        Program__c testProgram = testUtilities.CreateNewProgram(true);
        
        List<Membership__c> membs = new List<Membership__c>();
        Membership__c m1 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Earliest_Contract__c = c.Id, Membership_Status_Text__c = 'Prospect - Pure', Program__c = testProgram.Id);
        membs.add(m1);
        
        Membership__c m2 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Active_Contract_Idenfied__c = c.Id, Program__c = testProgram.Id);
        membs.add(m2);
        
        Membership__c m3 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Earliest_Contract__c = c1.Id, Active_Contract_Idenfied__c = c1.Id, Program__c = testProgram.Id);
        membs.add(m3);
        
        insert membs;
        
        set<id> memids = new set<Id>();
        memIds.add(m1.Id);
        memIds.add(m2.Id);
        
        insert opps;
        
        //Enable all the triggers
        Util.BypassAllTriggers = False;
        
        test.startTest();
        
        //Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out all values which is used to update Membership Owner		
        //Util.membershipOwnerCheckfromMemberships(memids);
             
        test.stopTest();
        
        m1 = [select id, Assigned_Marketer__c, OwnerId from Membership__c where id = :m1.Id];
        //system.assertEquals(m1.Assigned_Marketer__c, m1.OwnerId);
    }
    
    static testmethod void membershipOwnerCheckfromOpps()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Disable all triggers execution
        Util.BypassAllTriggers = true;
        
        Profile prof = [select id from Profile limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                timezonesidkey='America/Los_Angeles',
                ProfileId = prof.id, 
                username='testuser' + digit + '@advisory.com',
                IsActive = true
                ));
        }
        insert users; 
        User u1 = users[0];
        
        //Contact con1 = [select Id, Name from Contact where Counter_ID__c = :u1.Employee_Contact_RecordID__c limit 1];
        Contact con1 = new Contact(
            LastName = 'testcontact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con1;
        
        Account a = new Account(Name = 'TestAccount', EA_AE__c = u1.Id);
        insert a;
        
        Program__c p = new Program__c(Name='TestProg', Program_Acronym__c = 'ZTP');
        insert p;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = a.Id, Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1),stageName = 'pending', 
                                         CloseDate = system.today().addDays(32), Name = 'TestOpp', Amount = 1);
        opps.add(o1);
        
        Opportunity o2 = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = a.Id, StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1), 
                                         CloseDate = system.today().addDays(32), Name = 'TestOpp', Amount = 1);
        opps.add(o2);
        
        insert opps;
        
        //Program Susbcription record  
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed',Renewal_Opportunity__c  = opps[0].Id);
        //Insert 
        insert subscription;
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c = new Contract__c(Name = 'TestContract', Payer_Account__c = a.Id, Start__c = system.today().addDays(1), 
                                        End__c = system.today().addDays(3));
        contracts.add(c);
        Contract__c c1 = new Contract__c(Name = 'TestContract', Status__c = 'Honorary', Payer_Account__c = a.Id,
            Start__c = system.today().addDays(-1), End__c = system.today().addDays(5),
            Negotiated_Amount__c = 1, Type__c = 'Renewal', Year__c = '2011', Program__c = p.Id, Join_Date__c = System.today(),
            Main_Contact__c = con1.Id, Invoice_Contact__c = con1.Id, Contract_Renewal_Opportunity__c = o1.Id);
        contracts.add(c1);
        
        insert contracts;

        Program__c testProgram = TestUtilities.CreateNewProgram(true);
        
        List<Membership__c> membs = new List<Membership__c>();
        Membership__c m1 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Active_Subscription__c= subscription.Id,
                                              Active_Contract_Idenfied__c = c.Id,Earliest_Contract__c = c1.Id, Program__c = testProgram.Id,Membership_Status_Text__c = Constants.MEMBER_INTEGRATED_GRACE );
        membs.add(m1);
        
        Membership__c m2 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, Membership_Status_Text__c = Constants.MEMBER_INTEGRATED_GRACE,
                                             Active_Contract_Idenfied__c = c.Id, Program__c = testProgram.Id);
        membs.add(m2);
        insert membs;
        
        o1.Membership__c = m2.Id;
        
        //Update opportunity
        update o1;
        
        //Enable all the triggers
        Util.BypassAllTriggers = False;
        
        //Start testing from here
        Test.startTest();
        
        set<Id> selectoppids = new set<Id>();
        selectoppids.add(o1.Id);
        
        Util.membershipOwnerCheckfromOpps(selectoppids);
             
        Test.stopTest();
        
        //m1 = [select id, Assigned_Marketer__c, OwnerId from Membership__c where id = :m1.Id];
        //system.assertEquals(m1.Assigned_Marketer__c, m1.OwnerId);
    }
    
     static testmethod void membershipOwnerCheckfromOpps1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Disable all triggers execution
        Util.BypassAllTriggers = true;
        
        Profile prof = [select id from Profile limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                timezonesidkey='America/Los_Angeles',
                ProfileId = prof.id, 
                username='testuser' + digit + '@advisory.com',
                IsActive = true
                ));
        }
        insert users; 
        User u1 = users[0];
        
        //Contact con1 = [select Id, Name from Contact where Counter_ID__c = :u1.Employee_Contact_RecordID__c limit 1];
        Contact con1 = new Contact(
            LastName = 'testcontact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con1;
        
        Account a = new Account(Name = 'TestAccount', EA_AE__c = u1.Id);
        insert a;
        
        Program__c p = new Program__c(Name='TestProg', Program_Acronym__c = 'ZTP');
        insert p;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity o1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = a.Id, StageName = 'Pending', Chairman_s_Team_Rep__c = u1.Id, 
                                         Main_Contact__c = con1.Id, Start__c = system.today().addDays(-1), 
                                         CloseDate = system.today().addDays(32), Name = 'TestOpp', Amount = 1);
        opps.add(o1);
        
        insert opps;
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c c = new Contract__c(Name = 'TestContract', Payer_Account__c = a.Id, Start__c = system.today().addDays(1), 
                                        End__c = system.today().addDays(3));
        contracts.add(c);
        Contract__c c1 = new Contract__c(Name = 'TestContract', Status__c = 'Honorary', Payer_Account__c = a.Id,
                                         Start__c = system.today().addDays(-1), End__c = system.today().addDays(5),
                                         Negotiated_Amount__c = 1, Type__c = 'Renewal', Year__c = '2011', Program__c = p.Id, Join_Date__c = System.today(),
                                         Main_Contact__c = con1.Id, Invoice_Contact__c = con1.Id, Contract_Renewal_Opportunity__c = o1.Id);
        contracts.add(c1);
        
        insert contracts;

        Program__c testProgram = TestUtilities.CreateNewProgram(true);
        
        List<Membership__c> membs = new List<Membership__c>();
        Membership__c m1 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id,Membership_Status_Text__c = Constants.MEMBER_INTEGRATED_GRACE, 
                                             Active_Contract_Idenfied__c = c1.Id, Earliest_Contract__c = c1.Id, Program__c = testProgram.Id);
        membs.add(m1);
        
        Membership__c m2 = new Membership__c(Account_Name__c = a.Id, Name = 'TestMemb1', Assigned_Marketer__c = u1.id, 
                                             Active_Contract_Idenfied__c = c.Id, Program__c = testProgram.Id);
        membs.add(m2);
        insert membs;
        
        o1.Membership__c = m2.Id;
        
        //Update opportunity
        update o1;
        
        //Enable all the triggers
        Util.BypassAllTriggers = False;
        
        //Start testing from here
        Test.startTest();
        
        set<Id> selectoppids = new set<Id>();
        selectoppids.add(o1.Id);
        
        Util.membershipOwnerCheckfromOpps(selectoppids);
             
        Test.stopTest();
        
        //m1 = [select id, Assigned_Marketer__c, OwnerId from Membership__c where id = :m1.Id];
        //system.assertEquals(m1.Assigned_Marketer__c, m1.OwnerId);
    }
    
    
    static testmethod void testdeletememberships()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        Account a = new Account(Name = 'testaccount');
        insert a;
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(0, a.Memberships__r.size());
        
        
        List<Program__c> allprograms = new List<Program__c> (
            [select id From Program__c where Create_Memberships__c = 'Yes' limit 100]);
        
        List<Membership__c> newMsps = new List<Membership__c> ();
        for (Program__c prog: allprograms)
        {
            newMsps.add(new Membership__c (
                Program__c = prog.id, 
                Account_Name__c = a.id 
                ));
        }
        insert newMsps;     
        
        set<id> memids = new set<id>();
        for (Membership__c m : newMsps) memids.add(m.id);
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(allprograms.size(), a.Memberships__r.size());
        
        test.startTest();
        Util.deleteMemberships(memids);
        test.stopTest();
        
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        system.assertEquals(0, a.Memberships__r.size());
    }
    
    //Test method modified as according CR-20130531-3103 By Bhavi Sharma
    static testmethod void testmakememberships_v2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        list<Program__c> progs = [select Id, Applicable_Segments__c from Program__c 
            where Create_Memberships__c = 'Yes' and Applicable_Segments__c includes ('US Hospital')];
        //if (progs.size() > 0) delete progs;
        Integer progcount = progs.size();
    
        progs = new list<Program__c>();
        for (Integer i = 1; i <= 2; i++) {
            progs.add(new Program__c(
                Name = 'prog ' + i,
                Program_Acronym__c = 'TEST' + i,
                Create_Memberships__c = 'Yes',
                Applicable_Segments__c = 'US Hospital',
                Status__c = 'Active'
                ));
        }
        Util.BypassAllTriggers = true;
        insert progs;
        Util.BypassAllTriggers = false;
        progCount += progs.size();
                
        //Record type modified
        //List to hold insert accounts records
        List<Account> accounts = new List<Account>();
        accounts.add(TestUtilities.CreateNewAccount('US Education', false));
        accounts.add(TestUtilities.CreateNewAccount('US Education', false));
        accounts.add(TestUtilities.CreateNewAccount('US Education', false));
        
        // bypass Triggers so we don't auto generate memberships initially
        Util.BypassAllTriggers = true;
        //insert list of accounts
        insert accounts;
        Util.BypassAllTriggers = false;
        
        //query result of Accounts records
        accounts = [select id, Name, (select id from Memberships__r) from Account where Id IN :accounts];
        
        //assert Statement
        System.assertEquals(3, accounts.size());
        
        //Test starts here
        test.startTest();
        
        //Call Util class method
        Util.makeMembershipsforAccounts(new set<id>{ accounts[0].id, accounts[1].Id, accounts[2].Id });   
        
        //Test stops here
        test.stopTest();
                
        //query result of Accounts records
        accounts = [select id, Name, (select id, Name, Program__r.Program_Acronym__c from Memberships__r) 
                    from Account 
                    where Id IN: accounts ORDER BY Name];
        
        //List to hold Membership data associated with account
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Loop through accounts list 
        for(Account acc : accounts){
            
            //Loop through Account's membership list
            for (Membership__c mem : acc.Memberships__r) {
                
                //Check for Program's Program Acronym field value
                if (mem.Program__r.Program_Acronym__c == 'TEST1') {
                    
                    //assert statement
                    system.assertEquals(acc.Name + ' - ' + 'TEST1',mem.Name.substring(0,mem.Name.length()));
                }
                
                //Check for Program's Program Acronym field value
                if (mem.Program__r.Program_Acronym__c == 'TEST2') {
                    
                    //assert statement
                    system.assertEquals(acc.Name + ' - ' + 'TEST2',mem.Name.substring(0,mem.Name.length()));
                }
                
                //add membership into List
                memberships.add(mem);
            }
            
            //system.assertEquals(progCount, acc.Memberships__r.size());
        }
        
    }
    
    static testmethod void testIsValidEmailAddress()
    {
        System.assertEquals(true,Util.isValidEmailAddress('bob.frost@advisory.com'));
        System.assertEquals(true,Util.isValidEmailAddress('BOB.FROST@ADVISORY.COM'));
        System.assertEquals(true,Util.isValidEmailAddress('bobfrost@advisory.com'));
        System.assertEquals(true,Util.isValidEmailAddress('BOBFROST@ADVISORY.COM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROSTADVISORY.COM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORYCOM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORY.COMMM'));
        System.assertEquals(false,Util.isValidEmailAddress('BOB.FROST@ADVISORY.C'));        
    }
    
    static testmethod void testCreateSingleEmailInvalidRecipient()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'bo@.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(null,email);
    }
    
    static testmethod void testCreateSingleEmailInvalidReplyTo()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyToadvisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(null,email);
    }
    
    static testmethod void testCreateSingleEmailHappyPath()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        System.assertEquals(recipientEmails,email.getToAddresses());
        System.assertEquals(replyTo,email.getReplyTo());
        System.assertEquals(senderName,email.getSenderDisplayName());
        System.assertEquals(subject,email.getSubject());
        System.assertEquals(emailMessage,email.getHtmlBody());
        System.assertEquals(emailMessage,email.getPlainTextBody());
    }
    
    static testmethod void testSendEmailHappyPath()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        boolean result = Util.sendSingleEmail(email);
        System.assertEquals(true,result);
    }
    
    static testmethod void testSendEmailInvalidEmail()
    {
        Messaging.SingleEmailMessage email;
        List<String> recipientEmails = new List<String>{'johnsmith@advisory.com', 'test@advisory.com'};
        String replyTo = 'replyTo@advisory.com';
        String senderName = 'TestDisplayName';
        String subject = 'Test Subject';
        String emailMessage = 'This is a test!';
        email = Util.createSingleEmail(recipientEmails, replyTo, senderName, subject, emailMessage);
        email.setReplyTo('');
        boolean result = Util.sendSingleEmail(email);
        System.assertEquals(false,result);
    }
    
    //Added By - Mahendra Swarnkar - 12/07/2015 - CR-20151109-9376
    static testmethod void testformatToAlphabatical(){
        
        //String variable
        String value = 'ABC @abc# a1$ Z&XA^';
        
        //Test Starts from here
        Test.startTest();
        
        //Method call
        String value1 = Util.formatToAlphabatical(value);
        
        //Assert on results
        system.assertEquals('ABC abc a ZXA', value1);
        
        //Test stop here
        Test.stopTest();
    }
    //v1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 
    static testMethod void testBusinessHoursForStartAndEndDate(){
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        //Checking whether current is holiday or not
        Boolean isHoliday = Util.IsACompanyHoliday(Date.parse('08/25/2016'));
        isHoliday = Util.IsACompanyHoliday(Date.parse('08/24/2016'));
        isHoliday = Util.IsACompanyHoliday(Date.parse('09/20/2016'));
        isHoliday = Util.IsACompanyHoliday(Date.parse('09/25/2016'));
        isHoliday = Util.IsACompanyHoliday(Date.parse('08/01/2016'));
        
        //Checking for business time in total minutes
        Integer totalMinutes = Util.calculateBusinessHoursInMinute('08:30 AM');
        System.assert(totalMinutes != null);
        System.assertEquals(510, totalMinutes);
        totalMinutes = Util.calculateBusinessHoursInMinute('05:30 PM');
        System.assert(totalMinutes != null);
        System.assertEquals(1050, totalMinutes);
        
        //Checking for total business hour in minutes
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('08/25/2016 08:30 AM'), DateTime.parse('08/31/2016 05:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('08/30/2016 11:30 AM'), DateTime.parse('09/03/2016 09:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/10/2016 05:30 PM'), DateTime.parse('09/30/2016 09:30 AM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('10/10/2016 05:30 AM'), DateTime.parse('10/30/2016 09:30 AM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/12/2016 10:30 AM'), DateTime.parse('09/13/2016 03:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 10:30 AM'), DateTime.parse('09/13/2016 03:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 08:30 AM'), DateTime.parse('09/13/2016 05:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 08:30 AM'), DateTime.parse('09/13/2016 04:30 PM'));
        System.assert(totalMinutes != null);
        
        totalMinutes = Util.businessHoursForStartAndEndDate(DateTime.parse('09/13/2016 10:30 AM'), DateTime.parse('09/13/2016 06:30 PM'));
        System.assert(totalMinutes != null);
        
        Boolean isProduction = Util.IS_PRODUCTION_INSTANCE;
        Boolean isnotCompanyHoliday = Util.IsNotACompanyHoliday(System.today());
        String parseNull = Util.parseNull(null); 
        Integer bussinessDaysDiff = Util.bussinessDaysDifferenceInBetweenDates(System.today(), System.today().addDays(10));
        String daysString = Util.calculateDayOfDate(System.today());
        Date dt = Util.AddBusinessDays(System.today(), 3);
        
        //Stop test here
        Test.stopTest();
    }
    
    //v1.8 - Modified By - Mahendra Swarnkar - 10/16/2017 - Apollo Release 
    static testMethod void testValidateEntityValue1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Id prfid = [select id from Profile where Name = 'System Administrator' limit 1].id;
        system.assertnotEquals(null, prfid);
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        User userA = new User( alias = 'userA', 
                                email='SysAdmin@advisory.testtestcom', 
                                emailencodingkey='UTF-8', 
                                lastname='Testing', 
                                languagelocalekey='en_US', 
                                localesidkey='en_US', 
                                profileid = prfid, 
                                timezonesidkey='America/Los_Angeles', 
                                username='testuserZ' + randomInt + '@examplezzzyyyxx.com',
                                IsActive = true,
                                Entity__c = 'EAB',
                                ManagerId = UserInfo.getUserId());
        
        insert userA;
        
        //List to hold the Account record type's 
        List<RecordType> listAccountRecordTypes = [Select Id, DeveloperName from RecordType where sObjectType = 'Account' AND (DeveloperName =: 'Vendor' OR DeveloperName =: 'US_Corporate')];
        
        //String to hold the account's vendor record Type Id
        String rTypeIdVendor;
        
        //String to hold the account's US_Corporate record Type Id
        String rTypeIdUSCorporate;
        
        //Loop Over the record types
        for(RecordType rType : listAccountRecordTypes) {
            
            //Check for vendoe
            if(rType.DeveloperName == 'Vendor'){
                rTypeIdVendor = rType.Id;
            }
            
            //Check for vendoe
            if(rType.DeveloperName == 'US_Corporate'){
                rTypeIdUSCorporate = rType.Id;
            }    
        }
        
        //List to hold the Contact record type's 
        List<RecordType> listContactRecordTypes = [Select Id, DeveloperName from RecordType where sObjectType = 'Contact' AND (DeveloperName =: 'Employee' OR DeveloperName =: 'External' )];
        
        //String to hold the Contact's Employee record Type Id
        String rTypeIdConEmployee;
        
        //String to hold the Contact's External record Type Id
        String rTypeIdConExternal;
        
        //Loop Over the record types
        for(RecordType rType : listContactRecordTypes) {
            
            //Check for vendoe
            if(rType.DeveloperName == 'Employee'){
                rTypeIdConEmployee = rType.Id;
            }
            
            //Check for vendoe
            if(rType.DeveloperName == 'External'){
                rTypeIdConExternal = rType.Id;
            }    
        }
        
        //Map to hold the Opportunity record type's 
        Map<String,Id> mapOpportunityRecordTypes = new Map<String,Id>();
        
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
        for(RecordType rtype : [Select Id, DeveloperName from RecordType where sObjectType =: 'Opportunity' AND DeveloperName IN ('BI_Marketing',/*'Contract_LOA',*/ 'Royall' /*,'HC_Initiating'*/)]) {
            mapOpportunityRecordTypes.put(rtype.DeveloperName, rtype.Id);
        }
        
        
        /***** Parent SObject Records *****/
        
        //List to hold the parent sobject records
        List<SObject> listParentSObject = new List<SObject>();
        
        //Create 2 account 
        listParentSObject.add(new Account(Name = 'Test Account1', RecordTypeId = rTypeIdVendor));
        listParentSObject.add(new Account(Name = 'Test Account2', RecordTypeId = rTypeIdUSCorporate, Advisory_com_Organization_Status__c = 'active'));
        
        //Create Program record
        listParentSObject.add(new Program__c(Name = 'Test Program1', Create_memberships__c = 'No', Entity__c = 'EAB'));
        
        //Create Web Program Access record
        listParentSObject.add(new Web_Program_Access__c(Name = 'Test Web_Program_Access', Site__c = 'Advisory.com', Description__c = 'Test'));
        
        //Create Deployment Type record
        listParentSObject.add(new Deployment_Type__c(Name = 'Test Deployment Type'));
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        System.runAs(userA) {
        
            //Insert 
            insert listParentSObject;
            
            //Asserts on results
            System.assert(listParentSObject.size() > 0);
            
        }
        
        /***** CHild SObject Records__ 1 *****/
        
        //List to hold the Child sobject records
        List<SObject> listChildSObject1 = new List<SObject>();
        
        //Create 2 contact
        listChildSObject1.add(new Contact( RecordTypeID = rTypeIdConEmployee, AccountId = listParentSObject[1].Id, FirstName = 'Test', LastName = 'Contact 1', Employee_User_Record__c = userA.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                             Expert__c = true, Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true));
        listChildSObject1.add(new Contact( RecordTypeID = rTypeIdConExternal,  AccountId = listParentSObject[1].Id, FirstName = 'Test', LastName = 'Contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Bypass_Domain_Validation__c = true));
        
        //Create 1 Program_MTM
        //Spring clean up - listChildSObject1.add(new Program_MTM__c( Program__c = listParentSObject[2].Id));
        
        //Create 1 Web_Program_Access_MTM__c
        listChildSObject1.add(new Web_Program_Access_MTM__c( Web_Program__c = listParentSObject[3].Id, Membership_Program__c = listParentSObject[2].Id ));
        
        //Create 1 Membership record
        listChildSObject1.add(new Membership__c(Name = 'Test', Program__c = listParentSObject[2].Id, Account_Name__c = listParentSObject[1].Id )); 
        
        //Create 1 Project record
        //listChildSObject1.add(new Project__c(Name = 'Test Project', Product__c = listParentSObject[2].Id )); 
        
        //Create 1 Deployment record
        listChildSObject1.add(new Deployment__c( Deployment_Type__c = listParentSObject[4].Id, Institution__c =  listParentSObject[1].Id));
        
        System.runAs(userA) {
        
            //Insert
            insert listChildSObject1;
            
            List<Contact> contacts = [Select Id,Entity__c, AccountId From Contact where ID IN : listChildSObject1];
            
            //Asserts on results
            System.assert(contacts.size() > 0);
            System.assertEquals('EAB',contacts[0].Entity__c);
            System.assert(contacts[0].AccountId != null);
        }
        
        /***** CHild SObject Records__ 2 *****/
        
        //List to hold the Child sobject records
        List<SObject> listChildSObject2 = new List<SObject>();
        
        //Create 1 Expert_MTM
        listChildSObject2.add(new Expert_MTM__c( Expert__c = listChildSObject1[0].Id));
         //Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
        //Create 1 Temporary_Program_Access
        //listChildSObject2.add(new Temporary_Program_Access__c( Contact__c = listChildSObject1[0].Id, Web_Program__c = listChildSObject1[3].Id));
        
        //Create PSS Request record
        //listChildSObject2.add(new PSS_Request__c(Approver__c = listChildSObject1[0].Id, PSS_Rank__c = 'Primary', Reason_Requested__c = 'Test ABC',
        //                                      Resource_Requested__c = true));
        
        System.runAs(userA) {
          
            //Insert
            insert listChildSObject2;
        }
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By Dipesh Gupta - 03/25/2019 - CR-20190315-12944. - Commented out all the references. 
    //v1.8 - Modified By - Mahendra Swarnkar - 10/16/2017 - Apollo Release 
    static testMethod void testValidateEntityValue2() {
        try{
      //Bypass Dupeblocker
      Util.IsTest(true);
      Util.isTesting = true;
      
      //Bypassing Triggers so then test data can be created easily
      Util.byPassAllTriggers = true;
      
      Id prfid = [select id from Profile where Name = 'System Administrator' limit 1].id;
      system.assertnotEquals(null, prfid);
      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
      User userA = new User( alias = 'userA', 
                  email='SysAdmin@advisory.com', 
                  emailencodingkey='UTF-8', 
                  lastname='Testing', 
                  languagelocalekey='en_US', 
                  localesidkey='en_US', 
                  profileid = prfid, 
                  timezonesidkey='America/Los_Angeles', 
                  username='testuserZ' + randomInt + '@examplezzzyy.com',
                  IsActive = true,
                  Entity__c = 'EAB',
                  UserPermissionsMarketingUser = true);
      
      insert userA;
      
      //List to hold the Account record type's 
      List<RecordType> listAccountRecordTypes = [Select Id, DeveloperName from RecordType where sObjectType = 'Account' AND DeveloperName =: 'US_Corporate'];
      
      //Create 2 account 
      Account acc = new Account(Name = 'Test Account2', RecordTypeId = listAccountRecordTypes[0].Id, Advisory_com_Organization_Status__c = 'active', Entity__c = 'EAB', EAB_com_Organization_Status__c = 'active');
      insert acc;
      System.assert(acc.Id != null);
      
      //Create Program record
      Program__c prog = new Program__c(Name = 'Test Program1', Create_memberships__c = 'No', Entity__c = 'EAB');
      insert prog;
      
      //Map to hold the Contact record type's 
      Map<String,Id> mapContactRecordTypes = new Map<String,Id>();
      for(RecordType rtype : [Select Id, DeveloperName from RecordType where sObjectType = 'Contact' AND (DeveloperName =: 'Employee' OR DeveloperName =: 'External' )]) {
        mapContactRecordTypes.put(rtype.DeveloperName, rtype.Id);
      }
      
      //Create 2 contact
      List<Contact> contacts = new List<Contact>();
      contacts.add(new Contact( RecordTypeID = mapContactRecordTypes.get('Employee'), AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact 1', Employee_User_Record__c = userA.Id, Email = 'test@test.com', 
                         Expert__c = true, Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true));
      contacts.add(new Contact( RecordTypeID = mapContactRecordTypes.get('External'),  AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact 2', Email = 'test1@test.com', Bypass_Domain_Validation__c = true, Title = 'Test', Phone = '614-555-8855'));
      insert contacts;
      
      //Map to hold the Opportunity record type's 
      Map<String,Id> mapOpportunityRecordTypes = new Map<String,Id>();
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
            for(RecordType rtype : [Select Id, DeveloperName from RecordType where sObjectType =: 'Opportunity' AND DeveloperName IN ('BI_Marketing',/*'Contract_LOA',*/ 'Royall'/*,'HC_Initiating'*/)]) {
        mapOpportunityRecordTypes.put(rtype.DeveloperName, rtype.Id);
      }
      
      
      /***** Parent SObject Records *****/
      //List to hold the parent sobject records
      List<SObject> listParentSObject = new List<SObject>();
      //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
      //1 Create 4 Opportunity record
      listParentSObject.add(new Opportunity( Sales_Pursuit_Products__c = 'APS',Name = 'Test Opportunity1', RecordTypeId = mapOpportunityRecordTypes.get('BI_Marketing'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));
      //This recordType is inactive so commented.
      //listParentSObject.add(new Opportunity( Name = 'Test Opportunity2', RecordTypeId = mapOpportunityRecordTypes.get('Contract_LOA'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));
      listParentSObject.add(new Opportunity( Sales_Pursuit_Products__c = 'APS',Name = 'Test Opportunity1', RecordTypeId = mapOpportunityRecordTypes.get('BI_Marketing'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));
      listParentSObject.add(new Opportunity( Sales_Pursuit_Products__c = 'APS',Name = 'Test Opportunity3', RecordTypeId = mapOpportunityRecordTypes.get('Royall'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));
      listParentSObject.add(new Opportunity( Sales_Pursuit_Products__c = 'APS',Name = 'Test Opportunity4', RecordTypeId = mapOpportunityRecordTypes.get('Royall'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));
      listParentSObject.add(new Opportunity( Sales_Pursuit_Products__c = 'APS',Name = 'Test Opportunity5', RecordTypeId = mapOpportunityRecordTypes.get('Royall'), AccountId = acc.Id, CloseDate = system.today(), StageName = CPQConstants.OPPORTUNITY_STAGE_MQL, Amount = 20, Program__c = prog.Id));

        
        //Commented by Mahendar Swarnkar - 06/19/2019 - CR-20190524-13150
        //2Create Relationship Interaction Type record
        /*listParentSObject.add(new Relationship_Interaction__c(Name = 'Test Relationship Interaction', Institution__c = acc.Id,
                                                                Activity_Assigned_To__c = UserInfo.getUserId(), Primary_Contact__c = contacts[0].id, 
                                                                Start_Date_Time__c  = system.now(), End_Date_Time__c = system.now().addDays(1), 
                                                                Interaction_Level__c = 'In-person', Interaction_Type__c = 'Commercial', Assigned_To__c = UserInfo.getUserId() ));
        
        */
        //4
        //listParentSObject.add(new Meeting__c( Name = 'Test', Site__c = 'EAB.com'));
        //5
        listParentSObject.add(new Advisory_Twitter_Feed__c( Name = 'Test',Active__c = true, Applicable_For__c = 'EAB.com', Position__c = 1, Twitter_Username__c = 'Test'));
        
        //6 Insert Contracts
        listParentSObject.add(new Contract__c(Name = 'Test ContractABC1', Payer_Account__c = acc.Id, 
                                      Program__c = prog.Id, Invoicing_Arrangement__c = 'Annual', Main_Contact__c = contacts[0].Id,
                                      Invoice_Contact__c = contacts[1].Id, Year__c = '2016', Type__c = 'NBB', Start__c = System.today(),
                                      End__c = System.today().addDays(+10), Status__c = 'Pending', Term_Type__c = 'Opt Out', Years_in_Term__c = 2,
                                      Contract_Count__c = 2, Contract_Currency__c = 'EUR - Euro', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        
        
        //8 Restriction
        listParentSObject.add(new Restrictions__c( Name = 'Test', Expiration_Date__c = system.today().addDays(1), Category__c = 'Critical Background Information', Source_Department__c = 'AE' ));
        
        //9 Contract Integrated Account
        listParentSObject.add(new Contract_Integrated_Accounts__c(Name = 'Test',Account__c = acc.Id));
        
        
        //10 Campaign
        listParentSObject.add(new Campaign(Name = 'Test', Primary_Program__c = prog.id, Channel__c = 'Breakout', Status = 'Planned'));
        listParentSObject.add(new Campaign(Name = 'Test', Channel__c = 'Breakout', Status = 'Planned'));
        
        
        
        //List to hold the parent sobject records
        List<SObject> listParentSObject2 = new List<SObject>();
        
        //11 Create Other Utilization record
        listParentSObject2.add(new Other_Utilization__c( Institution__c = acc.Id));
        
        //12 Create Warm Lead record
        listParentSObject2.add(new Warm_Lead__c( Primary_Program__c = prog.Id ));
        
        //13 Create Eligible Domain record
        listParentSObject2.add(new Eligible_Domain__c( Account__c = acc.Id ));
        
        //14 Create Membership record
        listParentSObject2.add(new Membership__c( Account_Name__c = acc.Id, Program__c = prog.Id ));
        
        //15 Create Syndicated Study record
        listParentSObject2.add(new Syndicated_Study__c( name = 'Test', Primary_Program__c = prog.Id, Year__c = '2017'));
        
        //16 Create Publication record
        listParentSObject2.add(new Publication__c( Title__c = 'Test', Publication_Date__c = System.today(), Stock_Num__c = '2'));
        
        //Test Starts from here
        Test.startTest();
        
        System.runAs(userA) {
            
            Util.BypassAllTriggers = true;
            //Insert
            insert listParentSObject;
            insert listParentSObject2;
            //Util.BypassAllTriggers = true;
            
        }
        
        /***** CHild SObject Records__ 1 *****/
        
        //List to hold the Child sobject records
        List<SObject> listChildSObject1 = new List<SObject>();
        
        //1 Create 1 Program Reference MtM record
        listChildSObject1.add(new Program_Reference_MtM__c( Program__c = prog.Id/*, Relationship_Interaction__c = listParentSObject[4].Id*/));
       
      
      //3 ABC Revenue
      listChildSObject1.add(new ABC_Revenue__c(Contract_ABC__c = listParentSObject[7].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
      
      //4 Condition records
      //listChildSObject1.add(new Condition__c(Individual_Program__c = prog.Id, Condition_Type__c = 'Include', Standard_Goal__c =  listParentSObject[9].Id));
      
      //5
      listChildSObject1.add(new Restriction_Clearance_Request__c(Restriction__c = listParentSObject[8].Id, Previous_Evaluations_for_this_Product__c = 'Yes',
                                     Marketer__c = UserInfo.getUserId(), Contact__c = contacts[0].Id, Program__c = prog.Id, 
                                    Clearance_Approval_Response__c = 'Submitted, Response Pending', Clearance_Request_Comments__c = 'Test',
                                    Type_of_Interaction_Requested__c = 'schedule visit', Reason_for_Clearance_Request__c = 'MA Outreach',
                                    DateLastMarketingOutreachtoContact__c = system.today()));
      
      //6 Create Contracts to Contract Docs MtM record
      listChildSObject1.add(new Contracts_to_Contract_Docs_MtM__c( Contracts_ABC__c = listParentSObject[7].Id ));
      
      //7 Create NBB record
      listChildSObject1.add(new NBB__c( name = 'test', Program__c = prog.Id, opportunity__c = listParentSObject[0].Id ));
      
      
      // 8 Create Reference record
      listChildSObject1.add(new Reference__c( Contact_Name__c = contacts[0].Id, Institution__c = acc.Id, Membership__c = listParentSObject2[3].id,
                          Projected_Vetting_Date__c = system.today(), Reference_Module__c = 'CMA' ));
      
      //9 Create Membership Key Contacts record
      listChildSObject1.add(new Membership_Key_Contact__c( Membership__c = listParentSObject2[3].id, Contact__c = contacts[0].Id, Key_Contact_Status__c = 'Active'));
      
      
      /*
      //Create Publication Item record
      listChildSObject1.add(new Publication_Item__c( Publication__c = listParentSObject2[5].Id ));
      */
      
      System.runAs(userA) {
      
        //Util.BypassAllTriggers = false;
        //Insert
        insert listChildSObject1;
        Util.BypassAllTriggers = true;
      }
      
      /***** CHild SObject Records__ 2 *****/
      
      //List to hold the Child sobject records
      List<SObject> listChildSObject2 = new List<SObject>();
      
      //1 Create Publication Item record
      listChildSObject2.add(new Change_Reason__c( ABC_Revenue__c = listChildSObject1[1].Id ));
      
      System.runAs(userA) {
      
        //Util.BypassAllTriggers = false;
        //Insert
        insert listChildSObject2;
        Util.BypassAllTriggers = true;
      }
      
      //Insert Data
      insert new Expert_MTM__c();
      //Spring clean up - insert new Program_MTM__c();
      
      //Stop test here
      Test.stopTest();
      
      Util.disableDupeBlocker(true);
      Util.disableDupeBlocker(false);
      Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsCreate');
      Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsRead');
      Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsDelete');
      Util.createLog(Database.Upsert(new List<Program__c> {prog}, true));
      Util.createLog(Database.Delete(new List<Program__c> {}, true));
      //Commmented by Mahendra Swarnkar - 06/19/2019 - CR-20190524-13150
      //Util.companyHolidays();
      
      Util.errorHTMLLog(new Database.Error[] {});
    } catch(Exception e){
    
    }
    }
    
    static testMethod void test_CheckUserPermission()
    {
        test.startTest();
        Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'test');
        Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsCreate');
        Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsRead');
        Util.CheckUserPermission(UserInfo.getUserId(), new List<String>{'Account', 'Contact'}, 'PermissionsDelete');
        test.stopTest();
    }
    
    static testMethod void test_createLog()
    {
        //Create Program record
        Program__c prog = new Program__c(Name = 'Test Program1', Create_memberships__c = 'No', Entity__c = 'EAB');
        //insert prog;
        
        Util.createLog(Database.Insert(new List<Program__c> {prog}, true));
   }
    
    @isTest static void checkManagePackageAccess() {
             
        //Query on the Dipesh's User - He is not active on CPQ so he must not have the CPQ package assigned.
        List<User> dipeshUser = [Select Id From User Where UserName like '%dgupta@eab.com.eab%'];
        Boolean isCPQAccessible = Util.checkManagedPackageAccess(dipeshUser[0].Id, 'SBQQ');
        System.assertEquals(false, isCPQAccessible);
    }

    @isTest
    static void test_createLogDelete()
    {

        Util.IsTest(true);
        
        Util.isTesting = true;
      
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //Create Program record
        Program__c prog = new Program__c(Name = 'Test Program1', Create_memberships__c = 'No', Entity__c = 'EAB');
        insert prog;

        Test.startTest();
        prog.Name = 'Test Program2';
        String logMessage = Util.createLog(Database.upsert(new List<Program__c> {prog}));
        system.assertEquals('', logMessage);

        prog.Name =  null;
        prog.Create_memberships__c =  null;
        prog.Entity__c =  null;

        

        logMessage = Util.createLog(Database.upsert(new List<Program__c> {prog}));
        system.assertEquals('', logMessage);

        logMessage = Util.createLog(Database.delete(new List<Program__c> {prog}));
        system.assertEquals('', logMessage);

        logMessage = Util.createLog(Database.delete(new List<Program__c> {prog} , false));

        List<Contact> listOfContact = new List<Contact>();
        Contact cont = new Contact();
        listOfContact.add(cont);
        Database.Saveresult[] dsr = Database.insert(listOfContact,false);

        List<Database.Error> dbErrorList = new List<Database.Error>();
        for (Database.SaveResult sr : dsr) 
        {
            if (sr.isSuccess()) {}
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    dbErrorList.add(err);
                }
            }
        }

        
        logMessage  = Util.errorHTMLLog(dbErrorList);
        system.assert(logMessage != null);
        system.assertEquals('<table border="1"><tr><th>StatusCode</th><th>Message</th></tr><tr><td>FIELD_CUSTOM_VALIDATION_EXCEPTION</td><td>Email, Title and Phone are required for new active contacts or external contacts.</td></tr></table>', logMessage);

        Test.stopTest();
   }

   @isTest
   static void test_sendBatchStatus()
   {
    Test.startTest();
    Batch_MembershipNextActivityDate controller = new Batch_MembershipNextActivityDate(null);
    ID batchID = Database.executeBatch(controller, 200);

    Util.sendBatchStatus(batchID, 'Batch_MembershipNextActivityDate', 'Errors Exception Caused');
    AsyncApexJob[] jobs1 = [SELECT Id FROM AsyncApexJob where Id =: batchID AND JobType='BatchApex'];
    system.assertEquals(1 , Limits.getEmailInvocations());
    system.assertEquals(1 , jobs1.size());
    
    Util.sendBatchStatus(batchID, 'Batch_MembershipNextActivityDate', 'Test', 'test@test.com');
    AsyncApexJob[] jobs2 = [select Id from AsyncApexJob where Id =: batchID AND JobType='BatchApex'];

    system.assertEquals(2 , Limits.getEmailInvocations());
    system.assertEquals(1 , jobs1.size());
    Test.stopTest();
      
    }

    @isTest
   static void test_getDepartmentDivisionFunctionByCostCenter()
    {
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Department Division Function
        Department_Division_Function__c dDF = new Department_Division_Function__c(Name = 'Test', Cost_Center__c = '1213');
        insert dDF;

        system.assert(dDF != null);

        Util.byPassAllTriggers = false;
        Test.startTest();
        Map<String, Department_Division_Function__c> mapDepartmentDivisionFunction = new Map<String, Department_Division_Function__c>();
        mapDepartmentDivisionFunction = Util.getDepartmentDivisionFunctionByCostCenter(new Set<String> {'1213'});
        system.assert(mapDepartmentDivisionFunction != null);
        system.assertEquals(1, mapDepartmentDivisionFunction.size());
        system.assertEquals('1213', mapDepartmentDivisionFunction.get('1213').Cost_Center__c);
        Test.stopTest();
    }

    @isTest
    static void test_CalculateBusinessDays(){
        
        Date  startDate = date.newInstance(2020, 7, 15);
        Date endDate = startDate.addDays(10);
        Test.startTest();
        Integer businessDays = Util.CalculateBusinessDays(startDate, endDate, true, false);
        system.assertEquals(8,businessDays );
        Test.stopTest();
    }

    @isTest
    static void test_HtmlToText(){
        Test.startTest();
        Util.isTest(false);
        String HtmlToText = Util.HtmlToText('<h1>Hello world!</h1>');
        system.assertEquals('Hello world!', HtmlToText);
        Test.stopTest();
    }

    @isTest
    static void test_getPicklistValues(){
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Set<String> setProfileName = new Set<String>();
        Set<String> setPermissionSetName = new Set<String>();

        List<Schema.PicklistEntry> describeLineStatusValues = ABC_Revenue__c.Line_Status__c.getDescribe().getPicklistValues();
        Set<String> setLineStatusvalues = new Set<String>();

        String permissionName;

        for(PermissionSetAssignment pSA : [Select Id, PermissionSetId, PermissionSet.Name From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId()]){
            setPermissionSetName.add(pSA.PermissionSet.Name);
            permissionName = pSA.PermissionSet.Name;
        }
            


        Util.BypassAllTriggers = false;

        for(Schema.PicklistEntry f : describeLineStatusValues) {
            
            setLineStatusvalues.add(f.getLabel());
        }

        Test.startTest();
        setProfileName.add([Select Name From Profile Where Id =: UserInfo.getProfileId()].Name);
        List<String> filteredValues = Util.getPicklistValues(setProfileName, setPermissionSetName, 'ABC_Revenue__c', 'Line_Status__c', setLineStatusvalues);
        system.assertEquals(0, filteredValues.size());
        Test.stopTest();
    }

    @isTest
    static void test_getChronExpressionFromDateTime(){
        Test.startTest();
        String chronExpressionFromDateTime = Util.getChronExpressionFromDateTime(System.now().addSeconds(20));
        system.assert(chronExpressionFromDateTime != null);
        Test.stopTest();
    }
    
    /*
    @isTest
    static void test_unscheduleJobsWithoutNextFireDate(){
        Test.startTest();
        Account acc = new Account();
        acc.name = 'Test';
        insert acc;
        
        Schedule_Batch_UpdateMilestoneRevenue sched = new Schedule_Batch_UpdateMilestoneRevenue();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 0 15 3 ? 2022';
        String jobID = System.schedule('Testing Sched', sch, sched);
    
        Util.unscheduleJobsWithoutNextFireDate();
        List<CronTrigger> jobs = [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()];
        system.assertEquals(new List<CronTrigger> {}, jobs);

        Test.stopTest();
    }*/

    
    @isTest
    static void test_allFieldAPINames(){
        Test.startTest();
        String fieldNames  = Util.allFieldAPINames('Account');
        system.assert(fieldNames != null);
        system.assert(fieldNames.contains('id'));
        system.assert(fieldNames.contains('masterrecordid'));
        Test.stopTest();
    }
    
    @isTest
    static void test_sobjectRecordTypeId(){
        Test.startTest();
        Map<String, Id> mapSobjectRecordTypeId;
        mapSobjectRecordTypeId = Util.sobjectRecordTypeId('Project__c');
        system.assert(mapSobjectRecordTypeId != null);
        //system.assert(mapSobjectRecordTypeId.keySet().contains('ABSS'));
        system.assert(mapSobjectRecordTypeId.keySet().contains('APS'));
        Test.stopTest();

    }
   
    @isTest
    static void test_sobjectFieldSetNameWithSetOfFieldsAPIName(){
        Test.startTest();
        Map<String, Set<String>> mapSobjectFieldSetNameWithSetOfFieldsAPIName = new Map<String, Set<String>>();
        mapSobjectFieldSetNameWithSetOfFieldsAPIName = Util.sobjectFieldSetNameWithSetOfFieldsAPIName('Job_Ticket_MtM__c');
        system.assert(mapSobjectFieldSetNameWithSetOfFieldsAPIName != null);
        system.assert(mapSobjectFieldSetNameWithSetOfFieldsAPIName.size() > 0);
        system.assert(mapSobjectFieldSetNameWithSetOfFieldsAPIName.keySet().contains('Associated_Job_Components'));
        Test.stopTest();
    }

    

    @isTest
    static void test_getFieldSetFieldsAPINames(){
        Test.startTest();
        Set<String> setOfFieldsAPIName = util.getFieldSetFieldsAPINames('Job_Ticket__c', 'Vendor_JT_Callout_Field_Set');
        system.assert(setOfFieldsAPIName.size() > 0);
        system.assert(setOfFieldsAPIName.contains('Active_Production_Tracking__c'));
        Test.stopTest();
    }

    /* Commented By Rajeev Jain - 07/06/2020 - (This Method is already commented in Util Class for CR-20200102-13584)
    @isTest
    static void test_getCustomPermissionsReader(){
        Test.startTest();
        CustomPermissionsReader cPR = new CustomPermissionsReader();
        cPR = Util.getCustomPermissionsReader(); 
        system.assert(cPR != null);
        Test.stopTest();
    }*/

    @isTest
    static void test_getTheInstanceUrl(){
        Test.startTest();
        String result = Util.getTheInstanceUrl(); 
        system.assertEquals('null.salesforce.com', result);
        Test.stopTest();
    }

    @isTest
    static void test_returnDateOfSpecificDayOfSpecificWeek(){
        Test.startTest();
        List<String> weekDays = new List<String>{'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
        Date myDate = date.newinstance(2019, 12, 29);
        List<Date> returnDateForSun = new List<Date>();
        for(Integer i = 0 ; i< 7 ; i++)
        {
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDate.addDays(i)));
        }
        System.assertEquals(1,returnDateForSun[0].day());
        System.assertEquals(2,returnDateForSun[1].day());
        System.assertEquals(3,returnDateForSun[2].day());
        System.assertEquals(4,returnDateForSun[3].day());
        System.assertEquals(5,returnDateForSun[4].day());
        System.assertEquals(6,returnDateForSun[5].day());
        System.assertEquals(7,returnDateForSun[6].day());
        
        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[1], 0, null, myDate.addDays(1)));
        }catch(Exception e){
            system.assert(e.getMessage().contains('Please specify a non null and non zero value for week.'));
        }

        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[1], 0, null, null));
        }catch(Exception e){
            system.assert(e.getMessage().contains('Please specify a date value for further calculation.'));
        }

        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(null, 0, null, myDate.addDays(1)));
        }catch(Exception e){
            system.assert(e.getMessage().contains('Please specify the day value for the date for further calculation'));
        }

        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(null, 0, null, myDate.addDays(1)));
        }catch(Exception e){
            system.assert(e.getMessage().contains('Please specify the day value for the date for further calculation'));
        }

        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(null, -4, 0, myDate.addDays(1)));
        }catch(Exception e){
            system.assert(e.getMessage().contains('You can not specify both weeks and days for calculation prospective. Please specify only one of them.'));
        }

        try{
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(null, -4, 3 , myDate.addDays(1)));
        }catch(Exception e){
            system.assert(e.getMessage().contains('You can not specify both weeks and days for calculation prospective. Please specify only one of them.'));
        }

        try{
            Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[1], -4, 2, myDate.addDays(1));
        }catch(Exception e){
            system.assert(e.getMessage().contains('You can not specify both weeks and days for calculation prospective. Please specify only one of them.'));
        }
        Test.stopTest();
        
        
    }

    @isTest
    static void test_codeBypass (){
        Test.startTest();
        Util.codeBypassHelper  uCBH = new Util.codeBypassHelper();


        uCBH =  Util.codeBypass ;
        Set<String> mapSet  = uCBH.mapIdentifiers;
        system.assertEquals(0, mapSet.size());

        uCBH.add('ID1');

        Boolean bool = uCBH.contains('ID1');
        system.assertEquals(false, bool);
        Test.stopTest();
    }

    @isTest
    static  void test_areTriggersOnThisObjectBypassed(){
        Test.startTest();
        Boolean bypassTrigger  = Util.areTriggersOnThisObjectBypassed('Account');
        system.assertEquals(false, bypassTrigger);
        Test.stopTest();
    }
    
}