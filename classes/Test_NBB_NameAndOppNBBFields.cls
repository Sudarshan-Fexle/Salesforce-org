@isTest
private class Test_NBB_NameAndOppNBBFields
{
    /*
    Purpose		:   Test Trigger NBB_NameAndOppNBBFields
    
    Create By		:   Pierre Eymard (SAP Contractor)
    
    Last Modified By    :   Nathan Banas (SAP) - 2/9/2011
    
    Current Version	:   v1.2
    
    Revision Log	:   v1.0 - (PE) Created code
                            v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                            v1.2 - (NB-2011-02-09) - Added 'and Account.Name != null' to lines 25, 61, and 108 to account for data errors.
                                                 Also added UnitTest4 to test for NBB and NBB Units counts on Opps when the Type is not
                                                 in the criteria (NBB_Type__c = 'Base Fee' or 'Posted Risk')
                            v1.3 - Abhinav Sharma - 05/23/2014 - CR-20140415-5083 - Added the new method UnitTest5() method to test the functionality as per new changes
                            v1.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    Code Coverage as of 2/09/2011: 100%
    */
    
    
    static testmethod void UnitTest1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //test normal insert, delete functionality
        Util.isTesting = true;
        
        Util.byPassAllTriggers = true;
        
        User u = [select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1];
        
        // Create Acct, Prog, Opp
        Account testAcct = new Account(Name = 'Test Account', Account_Formal_Name__c = 'Test Account', Primary_City__c = 'Test', Primary_State_Province__c = 'DC');
        insert testAcct;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = testAcct.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        Program__c testProg = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'ZZ1');
        insert testProg;
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity o = new Opportunity(
            Name='Test Opp', 
            StageName = 'Pending', 
            Program__c = testProg.Id, 
            AccountId = testAcct.id,
            Main_Contact__c = cont.Id,
            recordTypeId = recordTypeId,
            CloseDate = system.today() + 1, NBB__c = 0, NBB_Units__c = 0, Sales_Pursuit_Products__c = 'APS');
        
        test.StartTest();
        
        Util.byPassAllTriggers = false;
        insert o;
        
        o = [select id, Program__r.Program_Acronym__c, Account.Name, NBB__c, NBB_Units__c 
            from Opportunity 
            where id = :o.id];
        
        testAcct = [select id, Name from Account where id = :testAcct.id];
        
        system.debug('### Test Account Name: ' + testAcct.name);
        
        NBB__c newnbb = new NBB__c(Opportunity__c = o.id, OwnerId = u.id, Program__c = testProg.id, Name = 'test', NBB_Type__c = 'Base Fee', NBB__c = 10, Unit__c = 5, 
                                        Marketer__c = u.id, ATL_Date__c = system.today());

        Double oldnbb = (o.NBB__c==null) ? 0 : o.NBB__c;
        Decimal oldnbbunit = (o.NBB_Units__c==null) ? 0 : o.NBB_Units__c ;
       
            insert newnbb;
        
        test.StopTest();
        
        //test name     
        newnbb = [select id, name, owner.lastname,ATL_Date__c  from NBB__c where id = :newnbb.id];
        
        // Debug info to be removed START
        system.debug('\n\nDebugging Fields\n');
        system.debug('###' + o.account + '\n');
        system.debug('###' + o.account.name + '\n');
        system.debug('###' + o.account + '\n');
        system.debug('###' + o.Program__c + '\n');
        system.debug('###' + o.Program__r.Program_Acronym__c + '\n');
        system.debug('###' + newnbb.owner + '\n');
        system.debug('###' + newnbb.owner.LastName + '\n');
        system.debug('###' + newnbb.ATL_Date__c.format() + '\n\n');
        // Debug info to be removed END
        
        String newname = 'NBB - ' + o.Account.Name.substring(0,(Math.min(55, o.Account.Name.length()))) 
            + ' - ' + o.Program__r.Program_Acronym__c + ' - ' + newnbb.owner.LastName + ' - ' + newnbb.ATL_Date__c.format();
        
        //System.assertEquals((newname).substring(0,Math.min(newname.length(), 80)), newnbb.name );
        
        //test Opp totals
        o = [select id, Marketer__c, NBB__c, NBB_Units__c from Opportunity where id = :o.id ];
        
        System.assertEquals(oldnbb + 10, o.NBB__c);
        System.assertEquals(oldnbbunit + 5, o.NBB_Units__c);            
        
        //test owner
        newnbb = [select id, OwnerID, Marketer__c from NBB__c where id = :newnbb.id];
        
        system.assertEquals(newnbb.Marketer__c, newnbb.OwnerID);   
    }
    
    static testmethod void UnitTest2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //test normal delete functionality
        Util.isTesting = true;
        
        id prfid = [select id from Profile where Name = 'Marketers' limit 1].id;
        
        list<User> users = new list<User>();
        
        Util.byPassAllTriggers = true;
        
        for (Integer i = 0; i < 2; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser123' + digit + '@advisorytest.com',
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prfid, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser19711' + digit + '@advisorytest.com'
                ));
            
        }
        insert users;
        
        Program__c testProg = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes');
        insert testProg;
        
        Account testAcct = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAcct;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = testAcct.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity o = new Opportunity(
            Name='Test Opp', 
            StageName = 'Pending', 
            Program__c = testProg.Id, 
            AccountId = testAcct.id,
            Main_Contact__c = cont.Id,
            CloseDate = system.today() + 1,
            recordTypeId = recordTypeId,
            NBB__c = 0, 
            NBB_Units__c = 0, Sales_Pursuit_Products__c = 'APS');
        
        test.StartTest();
        
        Util.byPassAllTriggers = false;
        insert o;
        
        o = [select id, Program__r.Program_Acronym__c, Account.Name, NBB__c, NBB_Units__c from Opportunity 
            where id = :o.id];
        o.Marketer__c = users[0].id; //removed 4/25/11 JN [select id from User where IsActive = true and ProfileId = :prfid limit 1].id;

        update o;
        
        NBB__c newnbb = new NBB__c(
            NBB_Type__c = 'Posted Risk',
            opportunity__c = o.id, Name = 'test', NBB__c = 10, Unit__c = 5, 
            Marketer__c = users[0].id, //[select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1].id, 
            ATL_Date__c = system.today());
        
        Double oldnbb = (o.NBB__c==null) ? 0 : o.NBB__c;
        Decimal oldnbbunit = (o.NBB_Units__c==null) ? 0 : o.NBB_Units__c ;

        insert newnbb;   
        
        //test name     
        newnbb = [select id, name, owner.lastname,ATL_Date__c  from NBB__c where id = :newnbb.id] ;
        String newname = 'NBB - ' + o.Account.Name.substring(0,(Math.min(55, o.Account.Name.length()))) 
            + ' - ' + o.Program__r.Program_Acronym__c + ' - ' + newnbb.owner.LastName + ' - ' + newnbb.ATL_Date__c.format();
        System.assertEquals((newname).substring(0,Math.min(newname.length(), 80)), newnbb.name );
        
        //test Opp totals
        o = [select id, Marketer__c, NBB__c, NBB_Units__c from Opportunity where id = :o.id ];
        System.assertEquals(oldnbb + 10, o.NBB__c);
        System.assertEquals(oldnbbunit + 5, o.NBB_Units__c);            
        
        //test owner
        newnbb = [select id, OwnerID, Marketer__c from NBB__c where id = :newnbb.id] ;
        system.assertEquals(newnbb.Marketer__c, newnbb.OwnerID);   
        
        delete newnbb;
        test.StopTest();
        
        //test opp totals
        o = [select id, NBB__c, NBB_Units__c from Opportunity where id = :o.id ];
        
        System.assertEquals(null, o.NBB__c);
        System.assertEquals(null, o.NBB_Units__c); 
    }
    
    static testmethod void UnitTest3()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Just like normal, but the opp won't save on update. 
        //should catch the exception caused by Opportunity trigger
        
        Util.isTesting = true;
        
        Util.byPassAllTriggers = true;
        
        id prfid = [select id from Profile where Name = 'Marketers' limit 1].id;
        list<User> users = new list<User>();
        
        for (Integer i = 0; i < 2; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standardUser1233' + digit + '@advisorytest.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prfid, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser19712' + digit + '@advisorytest.com'
                ));
            
        }
        insert users;
        
        Program__c testProg = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes');
        insert testProg;
        
        Account testAcct = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAcct;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = testAcct.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity o = new Opportunity(
            Name='Test Opp', 
            StageName = 'Pending', 
            Program__c = testProg.Id, 
            AccountId = testAcct.id,
            Main_Contact__c = cont.Id,
            CloseDate = system.today() + 1, 
            recordTypeId = recordTypeId,
            NBB__c = 0, 
            NBB_Units__c = 0,Sales_Pursuit_Products__c = 'APS');
        
        Util.byPassAllTriggers = false;
        
        test.StartTest();
        
        insert o;
        
        o = ([select id, Program__r.Program_Acronym__c, Account.Name, NBB__c, NBB_Units__c from Opportunity 
            where id = :o.id]);
        o.Marketer__c = users[0].id; //[select id from User where IsActive = true and ProfileId = :prfid limit 1].id;
        
        update o;
        
        NBB__c newnbb = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Base Fee', NBB__c = 10, Unit__c = 5, 
            Marketer__c = users[1].id, //[select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1].id, 
            ATL_Date__c = system.today());
        
        Double oldnbb = (o.NBB__c==null) ? 0 : o.NBB__c;
        Decimal oldnbbunit = (o.NBB_Units__c==null) ? 0 : o.NBB_Units__c ;
        
        insert newnbb;   
        
        //test name     
        newnbb = [select id, name, Marketer__c, owner.lastname, ATL_Date__c  from NBB__c where id = :newnbb.id] ;
        
        String newname = 'NBB - ' + o.Account.Name.substring(0,(Math.min(55, o.Account.Name.length()))) 
            + ' - ' + o.Program__r.Program_Acronym__c + ' - ' + newnbb.owner.LastName + ' - ' + newnbb.ATL_Date__c.format();
        
        System.assertEquals((newname).substring(0,Math.min(newname.length(), 80)), newnbb.name );
        
        //test Opp totals: lock the record so it can't be updated
        o = [select id, Marketer__c, NBB__c, NBB_Units__c from Opportunity where id = :o.id];
        System.assertEquals(oldnbb + 10, o.NBB__c);
        System.assertEquals(oldnbbunit + 5, o.NBB_Units__c);            
        
        //test owner
        newnbb = [select id, OwnerID, Marketer__c from NBB__c where id = :newnbb.id] ;
        system.assertEquals(newnbb.Marketer__c, newnbb.OwnerID);   
        
        //force exception on Opportunity trigger.
        Util.IsBreakMe = true;
        
        test.StopTest();
        
        try
        {       
            delete newnbb;
        }
        catch (Exception e)
        {
            system.debug('\n\n Exception caught: ' + e.getMessage());
        }
        
        //test opp totals: no change because of exception
        o = [select id, NBB__c, NBB_Units__c from Opportunity where id = :o.id ];
        
        System.assertEquals(oldnbb + 10, o.NBB__c);
        System.assertEquals(oldnbbunit + 5, o.NBB_Units__c);
    }
    
    static testmethod void UnitTest4()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //test normal insert, delete functionality when NBB should not count on Opp
        Util.isTesting = true;
        
        //Removed 4/25/11 JN
        //User u = [select id from User where IsActive = false limit 1];
        
        id prfid = [select id from Profile limit 1].id;
        
        list<User> users = new list<User>();
        
        for (Integer i = 0; i < 2; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='testuser19714' + digit + '@advisorytest.com',
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prfid, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser19714' + digit + '@advisorytest.com'
                ));
            
        }
        Util.byPassAllTriggers = true;
        insert users;
        
        Program__c testProg = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes');
        insert testProg;
        
        Account testAcct = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAcct;
        
       // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = testAcct.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity o = new Opportunity(
            Name='Test Opp', 
            StageName = 'Pending', 
            Program__c = testProg.Id, 
            AccountId = testAcct.id,
            Main_Contact__c = cont.Id,
            CloseDate = system.today() + 1, 
            recordTypeId = recordTypeId,
            NBB__c = 0, 
            NBB_Units__c = 0,Sales_Pursuit_Products__c = 'APS');
        
        Util.byPassAllTriggers = false;
        test.StartTest(); 
        
        insert o;
        
        o = ([select id, Program__r.Program_Acronym__c, Account.Name, NBB__c, NBB_Units__c from Opportunity 
            where id = :o.id]);
        
        NBB__c newnbb = new NBB__c(
            opportunity__c = o.id, 
            Name = 'test', 
            NBB_Type__c = 'Future Revenue', 
            NBB__c = 10, 
            Unit__c = 5, 
            Marketer__c = users[0].id, 
            ATL_Date__c = system.today());
        
        Double oldnbb = (o.NBB__c==null) ? 0 : o.NBB__c;
        Decimal oldnbbunit = (o.NBB_Units__c==null) ? 0 : o.NBB_Units__c ;

              
        insert newnbb;   
        test.StopTest();
        
        //test name     
        newnbb = [select id, name, owner.lastname, ATL_Date__c from NBB__c where id = :newnbb.id];
        
        String newname = 'NBB - ' + o.Account.Name.substring(0,(Math.min(55, o.Account.Name.length()))) 
            + ' - ' + o.Program__r.Program_Acronym__c + ' - ' + newnbb.owner.LastName + ' - ' + newnbb.ATL_Date__c.format();
        
        System.assertEquals((newname).substring(0,Math.min(newname.length(), 80)), newnbb.name );
        
        //test Opp totals
        o = [select id, Marketer__c, NBB__c, NBB_Units__c from Opportunity where id = :o.id ];
        
        System.assertEquals(null, o.NBB__c);
        System.assertEquals(null, o.NBB_Units__c);         
        
        //test owner
        newnbb = [select id, OwnerID, Marketer__c from NBB__c where id = :newnbb.id];
        
        system.assertEquals(newnbb.Marketer__c, newnbb.OwnerID);   
    }
    
    //Added By - Abhinav Sharma - 05/23/2014 - CR-20140415-5083
    static testmethod void UnitTest5() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test normal insert, delete functionality when NBB should not count on Opp
        Util.isTesting = true;
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert Account
        Account testAcct = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAcct;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Insert Program
        Program__c testProg = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert testProg;
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity o = new Opportunity(Name='Test Opp', Main_Contact__c = cont.Id, StageName = 'Pending', Program__c = testProg.Id, AccountId = testAcct.id, CloseDate = system.today() + 1,
                                        Sales_Pursuit_Products__c = 'APS',NBB__c = 0, NBB_Units__c = 0, recordTypeId = recordTypeId);
        insert o;
        
        //List to hold the NBB records
        List<NBB__c> nbbs = new List<NBB__c>();
        
        //List to hold the opportunity records
        List<Opportunity> opps = new List<Opportunity>();
        
        //NBB Records
        NBB__c newnbb_1 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Shadow Credit', NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today());
        NBB__c newnbb_2 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Future Revenue', NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today());
        NBB__c newnbb_3 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Base Fee', NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today());
        NBB__c newnbb_4 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Posted Risk', NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today());
        
        //Adding reocrds into the list
        nbbs.add(newnbb_1); nbbs.add(newnbb_2); nbbs.add(newnbb_3); nbbs.add(newnbb_4);
        
        //Start Test from here
        Test.startTest();
        
        //Setting flag value. So, then triggers can be excete again       
        Util.BypassAllTriggers = false;
        
        //Inserting NBB Records
        insert nbbs;  
        
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, NBB__c, NBB_Units__c FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(30, opps[0].NBB__c); 
        System.assertEquals(15, opps[0].NBB_Units__c); 
        
        //Making Update
        nbbs[0].NBB_Type__c = 'Future Revenue';
        nbbs[3].NBB_Type__c = 'Future Revenue';
        update nbbs;
        
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, NBB__c, NBB_Units__c FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(10, opps[0].NBB__c); 
        System.assertEquals(5, opps[0].NBB_Units__c); 
        
        //Stop test here 
        Test.StopTest();
        
        //Deleting out the record from the opportunity
        delete nbbs[2];
         
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, NBB__c, NBB_Units__c FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(null, opps[0].NBB__c); 
        System.assertEquals(null, opps[0].NBB_Units__c); 
        
    }
    

    //Added By - Mahendra Swarnkar - 07/22/2015 - CR-20150626-9028
    static testmethod void UnitTest6() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test normal insert, delete functionality when NBB should not count on Opp
        Util.isTesting = true;
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert Account
        Account testAcct = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAcct;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Insert Program
        Program__c testProg = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert testProg;
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity o = new Opportunity(Name='Test Opp', Main_Contact__c = cont.Id, StageName = 'Pending', Program__c = testProg.Id, AccountId = testAcct.id, CloseDate = system.today() + 1, 
                                        Sales_Pursuit_Products__c = 'APS',NBB__c = 0, NBB_Units__c = 0, recordTypeId = recordTypeId);
        insert o;
        
        //List to hold the NBB records
        List<NBB__c> nbbs = new List<NBB__c>();
        
        //List to hold the opportunity records
        List<Opportunity> opps = new List<Opportunity>();
        
        //NBB Records
        NBB__c newnbb_1 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Base Fee', NBB__c = 2000, Unit__c = 10, ATL_Date__c = system.today().addYears(-1));
        NBB__c newnbb_2 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Posted Risk', NBB__c = 3000, Unit__c = 10, ATL_Date__c = system.today().addYears(-2));
        NBB__c newnbb_3 = new NBB__c(opportunity__c = o.id, Name = 'test', NBB_Type__c = 'Shadow Credit', NBB__c = 4000, Unit__c = 10, ATL_Date__c = system.today());
        
        //Adding reocrds into the list
        nbbs.add(newnbb_1); nbbs.add(newnbb_2); nbbs.add(newnbb_3);
        
        //Start Test from here
        Test.startTest();
        
        //Setting flag value. So, then triggers can be excete again       
        Util.BypassAllTriggers = false;
        
        //Inserting NBB Records
        insert nbbs;  
        
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, Current_YTD_NBB_New__c, Current_YTD_NBB_Units_New__c, Previous_YTD_NBB_New__c,
                Previous_YTD_NBB_Units_New__c, Previous_Year_NBB_New__c, Previous_Year_NBB_Units_New__c
                FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(4000, opps[0].Current_YTD_NBB_New__c); 
        System.assertEquals(10, opps[0].Current_YTD_NBB_Units_New__c);
        System.assertEquals(2000, opps[0].Previous_YTD_NBB_New__c);
        System.assertEquals(10, opps[0].Previous_YTD_NBB_Units_New__c);
        System.assertEquals(2000, opps[0].Previous_Year_NBB_New__c);
        System.assertEquals(10, opps[0].Previous_Year_NBB_Units_New__c);
        
        //Making Update
        nbbs[2].ATL_Date__c = system.today().addYears(1);
        update nbbs;
        
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, Current_YTD_NBB_New__c, Current_YTD_NBB_Units_New__c, Previous_YTD_NBB_New__c,
                Previous_YTD_NBB_Units_New__c, Previous_Year_NBB_New__c, Previous_Year_NBB_Units_New__c
                FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(0, opps[0].Current_YTD_NBB_New__c); 
        System.assertEquals(0, opps[0].Current_YTD_NBB_Units_New__c);
        System.assertEquals(2000, opps[0].Previous_YTD_NBB_New__c);
        System.assertEquals(10, opps[0].Previous_YTD_NBB_Units_New__c);
        System.assertEquals(2000, opps[0].Previous_Year_NBB_New__c);
        System.assertEquals(10, opps[0].Previous_Year_NBB_Units_New__c);
        
        //Stop test here 
        Test.StopTest();
        
        //Deleting out the record from the opportunity
        delete nbbs[0];
         
        //Retrieving updated opportunity reocrd details (field values)
        opps = [Select ID, Current_YTD_NBB_New__c, Current_YTD_NBB_Units_New__c, Previous_YTD_NBB_New__c,
                Previous_YTD_NBB_Units_New__c, Previous_Year_NBB_New__c, Previous_Year_NBB_Units_New__c
                FROM opportunity LIMIT 1];
        
        //Assert for the results
        System.assertEquals(0, opps[0].Current_YTD_NBB_New__c); 
        System.assertEquals(0, opps[0].Current_YTD_NBB_Units_New__c);
        System.assertEquals(0, opps[0].Previous_YTD_NBB_New__c);
        System.assertEquals(0, opps[0].Previous_YTD_NBB_Units_New__c);
        System.assertEquals(0, opps[0].Previous_Year_NBB_New__c);
        System.assertEquals(0, opps[0].Previous_Year_NBB_Units_New__c);
        
    }
}