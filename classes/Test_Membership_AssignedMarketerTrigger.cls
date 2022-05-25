@isTest
private class Test_Membership_AssignedMarketerTrigger
{
    /*
    Purpose:    Test Trigger Membership_PopulateAssignedMarketer
    
    Create By:  Angela Williams (SAP Contractor)            
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-24 thru 2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.2 - (Bhavi - 11/07/2012) - CR-20121019-1641
                        v1.1 - (SUNJ 12/19/13) - CR-20130118-2218
                        v1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    Code Coverage as of 1/25/2011: 100%
    */

    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];

    static testmethod void testCase1(){ 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // setup the custom setting
        Util.resetRecordtypeSettings();
        
        system.debug('### Test Case 1 ###');
        
        Account acc = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', Core_Programs_Available_for_Outreach__c = '', EAB_com_Organization_Status__c = 'Active');
        insert acc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
        
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='Test Update', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg2;
        
        AccountTeamMember accMember = new AccountTeamMember(
            UserId = usr.Id,
            AccountId = acc.Id,
            TeamMemberRole = testProg1.New_Business_Marketer__c);
            //AccountAccessLevel = 'Read');
        insert accMember;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity testOpp = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp', Main_Contact__c = cont.Id, StageName = '0-Exploring', Amount=1, CloseDate = System.today().addDays(32), AccountId = acc.Id);
        insert testOpp;
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = acc.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = testOpp.Id
            );
            
        insert testContract1;
        Util.byPassAllTriggers = false;
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        Membership__c member1 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id,
            Active_Contract_Idenfied__c = testContract1.Id);
        
        memberships.add(member1);
        
        Membership__c member2 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            OwnerId = usr.Id,
            Program__c = testProg1.Id,
            Assigned_Marketer__c = usr.Id);
        
        memberships.add(member2);
        
        Membership__c member3 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id,
            OwnerId = usr.Id,
            Assigned_Marketer__c = usr.Id);
        
        test.startTest();
          
        Util.IsBatch = false;  
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        insert memberships;
        insert member3;
        
        //Util
        util.BypassAllTriggers = true;
        Contact con = new Contact(FirstName = 'First', LastName = 'Last', Email = 'test@test.com', 
                                  AccountId = acc.Id, Bypass_Domain_Validation__c = true, 
                                  Employee_User_Record__c = Userinfo.getUserId(), Contact_Status__c  = 'Active', 
								  Title = 'Test', Phone = '614-555-8855');
        insert con;
       
        Membership_Key_Contact__c testMembershipKeyContact = new Membership_Key_Contact__c(
            Contact__c = con.id,
            Name='Test 1', 
            Role_Type__c = 'PT', 
            Role__c = 'Exec Sponsor', 
            Membership__c = member1.Id,
            Pubs__c = true,
            Meetings__c = true,
            Key_Contact_Status__c = 'Active'
        );
        
		
        //Query on the User to get only those User which has role = Shard Swervice so that Validation rule can be Bypass.
        List<User> u = [Select Id From user Where UserRole.Name = 'Shared Services' AND isActive = true And Profile.Name = 'System Administrator'];
        
        System.runAs(u[0]) {
            
        	insert testMembershipKeyContact;
        
        }
		
        //Stop test here    
        Test.stopTest();
        
        member1 = [select id, Membership_Status__c, OwnerId, Assigned_Marketer__c, Active_Contract_Idenfied__c, Latest_Contract__c, Earliest_Contract__c from Membership__c where Id = :member1.Id];
        member2 = [select id, Membership_Status__c, OwnerId, Assigned_Marketer__c, Active_Contract_Idenfied__c, Latest_Contract__c, Earliest_Contract__c from Membership__c where Id = :member2.Id];
        
        system.debug('\n\nm1.Membership_Status__c ' + member1.Membership_Status__c);        
        system.debug('\n\nm2.Membership_Status__c ' + member2.Membership_Status__c);
        
        system.debug('\n\nm1.OwnerId ' + member1.OwnerId);      
        system.debug('\n\nm2.OwnerId ' + member2.OwnerId);
        
        system.debug('\n\nm1.Assigned_Marketer__c ' + member1.Assigned_Marketer__c);        
        system.debug('\n\nm2.Assigned_Marketer__c ' + member2.Assigned_Marketer__c);
        
        System.assertNotEquals(null, member1.Active_Contract_Idenfied__c);
        System.assert(member1.Assigned_Marketer__c == usr.Id,'Test Failed as Trigger dint function properly');
        
        System.assertEquals(null, member2.Active_Contract_Idenfied__c);
        System.assertEquals(null, member2.Latest_Contract__c);
        System.assertEquals(null, member2.Earliest_Contract__c);
        
        //Test Case for - CR-20121019-1641
        //member2.Program__c = testProg1.Id;
        member2.Active_Contract_Idenfied__c = testContract1.Id;
        update member2;
        
        member2 = [select id, Membership_Status__c, OwnerId, Assigned_Marketer__c, Active_Contract_Idenfied__c, Latest_Contract__c, Earliest_Contract__c from Membership__c where Id = :member2.Id];
        system.debug('\n\nm2.Membership_Status__c ' + member2.Membership_Status__c);
        
        //Assert for the result
        con = [Select Id, Membership_Contact_Pubs__c, Membership_Contact_Meetings__c from Contact where Id =: con.Id];
        //System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Pubs__c);
        //System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Meetings__c);
        
    }
    
    /*
    static testmethod void testcountMemberships()
    {
        Util.IsTest(true);
        system.debug('### Test Case 2 ###');
        
        Util.isTesting = true;
        
        Account acc = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', Core_Programs_Available_for_Outreach__c = '');
        insert acc;
        
        //Added 4/21/11 JN
        Program__c testprog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST');
        insert testprog;
        
        set<String> businesslineset = new set<String>{ 'TD', 'RI', 'PT', 'CM' };
        
        Contact con = new Contact(RecordTypeId = Util.recordtypemap('Contact').get('External'), FirstName = 'Test', LastName = 'testcon', AccountId = acc.id);
        insert con;
        
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c cont = new Contract__c(
            Status__c = 'Honorary',
            Payer_Account__c = acc.id,
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Start__c = system.today().addDays(-1),
            End__c = system.today().addDays(2),
            Year__c = String.valueof(system.today().year()),
            Program__c = testprog.id, //Removed 4/21/11 JN [select id from Program__c limit 1].id,
            Join_Date__c = system.today(),
            Main_Contact__c = con.id,
            Invoice_Contact__c = con.id
            );
        contracts.add(cont);
            
        Contract__c cont1 = new Contract__c(
            Status__c = 'Honorary',
            Payer_Account__c = acc.id,
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Start__c = system.today().addDays(1),
            End__c = system.today().addDays(2),
            Year__c = String.valueof(system.today().year()),
            Program__c = [select id from Program__c limit 1].id,
            Join_Date__c = system.today(),
            Main_Contact__c = con.id,
            Invoice_Contact__c = con.id
            );
        contracts.add(cont1);
        
        insert contracts;
        
        List<Program__c> progs = new list<Program__c>();
        
        progs.add(new Program__c(Name = 'Test1', Create_Memberships__c = 'No', Business_Line__c = 'TD', New_Business_Marketer__c = null, Renewal_Unit_Count__c = 1, Program_Acronym__c = 'Aca'));
        progs.add(new Program__c(Name = 'Test2', Create_Memberships__c = 'No', Business_Line__c = 'PT', New_Business_Marketer__c = null, Renewal_Unit_Count__c = 1, Program_Acronym__c = 'BI'));
        progs.add(new Program__c(Name = 'Test3', Create_Memberships__c = 'No', Business_Line__c = 'RI', New_Business_Marketer__c = null, Renewal_Unit_Count__c = 1, Program_Acronym__c = 'COR'));
        progs.add(new Program__c(Name = 'Test4', Create_Memberships__c = 'No', Business_Line__c = 'CM', New_Business_Marketer__c = null, Renewal_Unit_Count__c = 1, Program_Acronym__c = 'HW'));

        insert progs;
        
        progs = [select id, New_Business_Marketer__c, Renewal_Unit_Count__c, Program_Acronym__c, Business_Line__c from Program__c where Id in :progs];
        
        system.debug('### Test Programs: ' + progs);
        
        //Testing for PT, RI, TD, and CM Unit Count rollups to Account
        list<Membership__c> testmems = new list<Membership__c>();
        
        for (Program__c prog : progs)
        {
            Membership__c m = new Membership__c(
                Active_Contract_Idenfied__c = cont.id,
                Account_Name__c = acc.id,
                Program__c = prog.id,
                OwnerId = usr.id,
                Assigned_Marketer__c = usr.id
                );
                
            testmems.add(m);
        }
        
        test.startTest();
        
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        insert testmems;
        
        testmems = [select id, Program__c, Program__r.Business_Line__c, Account_Name__c, Membership_Status__c, Prospect_Status__c, Active_Contract_Idenfied__c, Earliest_Contract__c, 
            Payer_Status__c, Active_Contract_Status__c, Start_Date_on_First_Contract__c, Active_Contract_End_Date__c, Most_Recent_Lost_Opportunity_Close_Date__c, Renewal_Unit_Count__c
            from Membership__c where Account_Name__c = :acc.id and id in :testmems];

        for (Membership__c m : testmems) {
            system.debug('\n\n116 m.Membership_Status__c ' + m.Membership_Status__c);
            system.debug('\n\n116 m.Prospect_Status__c ' + m.Prospect_Status__c);
            system.debug('\n\n116 m.Most_Recent_Lost_Opportunity_Close_Date__c ' + m.Most_Recent_Lost_Opportunity_Close_Date__c);
            system.debug('\n\n116 m.Program__r.Business_Line__c ' + m.Program__r.Business_Line__c);
            system.assert(m.Prospect_Status__c.contains('Member'));
            system.assertEquals(1, m.Renewal_Unit_Count__c);
            system.assert(businesslineset.contains(m.Program__r.Business_Line__c));
        }

        system.debug('### Test Memberships: ' + testmems);

        acc = [select Id, Name, Academies_Memberships__c, Core_Memberships__c, BI_Memberships__c, Hworks_Memberships__c,
            (select id, Program__r.Business_Line__c, Membership_Status__c, Renewal_Unit_Count__c from Memberships__r)
            from Account where Id = :acc.Id];
            
            
        system.assertNotEquals(null, acc.Academies_Memberships__c);
        system.assertNotEquals(null, acc.BI_Memberships__c);
        system.assertNotEquals(null, acc.Core_Memberships__c);
        system.assertNotEquals(null, acc.Hworks_Memberships__c);
        

        // Testing for  PT, RI, TD rollup of Program Acronyms to Account        
        list<Membership__c> testmems1 = new list<Membership__c>();
        
        for (Program__c prog : progs)
        {
            Membership__c m = new Membership__c(
                Active_Contract_Idenfied__c = cont.id,
                Account_Name__c = acc.id,
                Program__c = prog.id,
                Earliest_Contract__c = cont1.id,
                Most_Recent_Lost_Opportunity_Close_Date__c = System.today().addDays(-180),
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                Most_Recent_NBB_Visit__c = null
                );
                
            testmems1.add(m);
        }
        
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        insert testmems1;
        
        test.stopTest();
        
        testmems1 = [select id, Program__c, Program__r.Business_Line__c, Account_Name__c, Membership_Status__c, Membership_Status_Text__c, Prospect_Status__c, Active_Contract_Idenfied__c, Earliest_Contract__c, 
            Payer_Status__c, Active_Contract_Status__c, Start_Date_on_First_Contract__c, Active_Contract_End_Date__c, Most_Recent_Lost_Opportunity_Close_Date__c, Renewal_Unit_Count__c
            from Membership__c where Account_Name__c = :acc.id and id in :testmems1];
        
        for (Membership__c m : testmems1) {
            system.debug('\n\n116 m.Membership_Status__c ' + m.Membership_Status__c + ':::::Membership_Status_Text__c' + m.Membership_Status_Text__c);
            system.debug('\n\n116 m.Prospect_Status__c ' + m.Prospect_Status__c);
            system.debug('\n\n116 m.Most_Recent_Lost_Opportunity_Close_Date__c ' + m.Most_Recent_Lost_Opportunity_Close_Date__c);
            system.debug('\n\n116 m.Program__r.Business_Line__c ' + m.Program__r.Business_Line__c);
            system.assertEquals('Available For Outreach', m.Prospect_Status__c);
            system.assertEquals(1, m.Renewal_Unit_Count__c);
            system.assert(businesslineset.contains(m.Program__r.Business_Line__c));
        }
        
        system.debug('### Test Memberships: ' + testmems1);
        
        acc = [select Id, Name, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c, Core_Programs_Available_for_Outreach__c,
            (select id, Program__r.Business_Line__c, Membership_Status__c, Renewal_Unit_Count__c from Memberships__r)
            from Account where Id = :acc.Id];

        system.debug('### Test Account After Updates: ' + acc);
        system.debug('### Test Account Academy_Programs_Available_for_Outreach__c (After Updates): ' + acc.Academy_Programs_Available_for_Outreach__c);
        system.debug('### Test Account BI_Programs_Available_for_Outreach__c (After Updates): ' + acc.BI_Programs_Available_for_Outreach__c);
        system.debug('### Test Account Core_Programs_Available_for_Outreach__c (After Updates): ' + acc.Core_Programs_Available_for_Outreach__c);
        system.debug('### Test Account Memberships Count: ' + acc.Memberships__r.size());
        
        system.assertEquals('Aca', acc.Academy_Programs_Available_for_Outreach__c);
        system.assertEquals('BI', acc.BI_Programs_Available_for_Outreach__c);
        system.assertEquals('COR', acc.Core_Programs_Available_for_Outreach__c);
    }
    
    static testmethod void testContractNulling()
    {
        Util.IsTest(true);
        
        Account acc = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', Core_Programs_Available_for_Outreach__c = '');
        insert acc;
        
        Contact con = new Contact(RecordTypeId = Util.recordtypemap('Contact').get('External'), FirstName = 'Test', LastName = 'testcon', AccountId = acc.id);
        insert con;
        
        Program__c prog = new Program__c(
            New_Business_Marketer__c = 'RI Marketer',
            Program_Acronym__c = 'ZZ1');
        insert prog; 
        
        Contract__c testCont = new Contract__c(
            Status__c = 'Honorary',
            Payer_Account__c = acc.id,
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Start__c = system.today().addDays(-1),
            End__c = system.today().addDays(2),
            Year__c = String.valueof(system.today().year()),
            Program__c = [select id from Program__c limit 1].id,
            Join_Date__c = system.today(),
            Main_Contact__c = con.id,
            Invoice_Contact__c = con.id
            );
        
        insert testCont;
        
        Membership__c testMem = new Membership__c(
            Account_Name__c = acc.Id,
            Active_Contract_Idenfied__c = testCont.Id,
            Earliest_Contract__c = testCont.Id,
            Latest_Contract__c = testCont.Id,
            Program__c = prog.Id);
        
        test.startTest();
            
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        insert testMem;
        
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;

        testMem.Program__c = null;
        update testMem;
        
        testMem = [select Id, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where Id = :testMem.Id];
        
        system.assertEquals(null, testMem.Active_Contract_Idenfied__c);
        system.assertEquals(null, testMem.Earliest_Contract__c);
        system.assertEquals(null, testMem.Latest_Contract__c);
        
        test.stopTest();
    }*/
}