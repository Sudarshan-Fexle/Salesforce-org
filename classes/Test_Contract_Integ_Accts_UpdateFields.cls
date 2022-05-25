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

//Modified By Rajeev Jain - CR-20180607-12272 - 07/19/2018 - Increase the coverage to make the Deployment partial. 
//Coverage is 78%
//Modified By Abhisekh Mishra - CR-20210517-15151 - 06/28/2021 - Increase code coverage
//Modified By - Shalu Sharma - 07/27/2021 - CR-20210621-15227 - Update "testCreateMemberships" method
//Modified by - Mahendra Swarnkar - 09/21/2021 - CR-20210831-15398
@isTest
private class Test_Contract_Integ_Accts_UpdateFields
{

    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testMembershipActiveContractfields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Util.IsTesting = true;
        Util.IsTestingContractIntegratedAcct = true;		
	Util.ByPassAllTriggers = true;
		
        //Removed 4/22/11 JN
        //Account testAcct1 = [select Id, Name from Account limit 1];
        Account testAcct1 = new Account(Name = 'testacct1', Account_Formal_Name__c = 'testacct1');
        insert testAcct1;
        
        //Removed 4/22/11 JN
        //Program__c[] testProgs = [select Id, Name, Program_Acronym__c, Create_Memberships__c from Program__c where Create_Memberships__c = 'No' and Program_Acronym__c != null limit 2];
        list<Program__c> testProgs = new list<Program__c>();
        for (Integer i = 0; i < 3; i++) {
            testProgs.add(new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST'));
        }
        insert testProgs;
        Program__c testProg1 = testProgs[0];
	
	//CR-20210831-15398 - update false to true
	Util.ByPassAllTriggers = true;
        
        List<Membership__c> memInsert = new List<Membership__c>();
        
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
            
        memInsert.add(testMembership1);
        
        Membership__c testMembership2 = new Membership__c(
            Name='Test Membership 2', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
        
        memInsert.add(testMembership2);
        
        insert memInsert;
        
        list<Contract__c> testContracts = new list<Contract__c>();
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProgs[1].Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract2);   
        insert testContracts;
        
        //Creating a standard contract
        Contract standardContract = TestUtilities.createNewStandardContract(testAcct1.id, true);
	
        list<Contract_Integrated_Accounts__c> cias = new list<Contract_Integrated_Accounts__c>();
        Contract_Integrated_Accounts__c cia1 = new Contract_Integrated_Accounts__c(
        Account__c = testAcct1.id,
        Contract__c = testContract1.id, LOA_Contract__c = standardContract.Id); 
        cias.add(cia1);
        Contract_Integrated_Accounts__c cia2 = new Contract_Integrated_Accounts__c(
        Account__c = testAcct1.id,
        Contract__c = testContract2.id); 
        cias.add(cia2);
        insert cias;
        
        cia1 = [select Id, Name, Account__c, Contract__c from Contract_Integrated_Accounts__c where Id = :cia1.id];
        testMembership1 = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
        
	//CR-20210831-15398
        test.startTest();
	
        // Validate Name
        testAcct1 = [select Id, Name from Account where id = :testAcct1.id];
        string nameChecker = testAcct1.Name.substring(0, Math.Min(55, testAcct1.Name.Length())) + ' - ' +
        testProg1.Program_Acronym__c + ' - '  + testContract1.Year__c + ' - Int';
        nameChecker = nameChecker.substring(0, Math.min(nameChecker.Length(), 80));
        
        
	test.stopTest();
    }
    
    //Modified By Dipesh Gupta - Rev Mgmt 606 Production validation failure fixes. 11/08/2017 - used Util.ByPassAllTrigger flag to avoid unwanted code run.
    // Test deleting Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testdeleteMembershipActiveContractfields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Util.IsTesting = true;
        //Util.IsTestingContractIntegratedAcct = true;
        
         //Bypass All triggers
        Util.BypassAllTriggers = true;
        
        //Removed 4/22/11 for new data JN
        //list<Account> testAccts = [select Id, Name from Account limit 2];
        list<Account> testAccts = new list<Account>();
        for (Integer i = 0; i < 3; i++) {
            testAccts.add(new Account(Name = 'testacct', Account_Formal_Name__c = 'testacct' + String.valueOf(i)));
        }
        insert testAccts;
        
        Account testAcct1 = testAccts[0];
        Account testAcct2 = testAccts[1];
        //Removed 4/22/11 JN
        //Program__c[] testProgs = [select Id, Name, Program_Acronym__c, Create_Memberships__c from Program__c where Create_Memberships__c = 'No' and Program_Acronym__c != null limit 2];
        list<Program__c> testProgs = new list<Program__c>();
        for (Integer i = 0; i < 3; i++) {
            testProgs.add(new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST'));
        }
        insert testProgs;
            
        Program__c testProg1 = testProgs[0];
        
        List<Membership__c> memInsert = new List<Membership__c>();
        
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
            
        memInsert.add(testMembership1);
        
        insert memInsert;
        
        list<Contract__c> testContracts = new list<Contract__c>();
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct1.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 5, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract',
            Payer_Account__c = testAcct2.Id,
            Program__c = testProg1.Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 5,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped');
        testContracts.add(testContract2);   
        insert testContracts;
        
        list<Contract_Integrated_Accounts__c> cias = new list<Contract_Integrated_Accounts__c>();
        Contract_Integrated_Accounts__c cia2 = new Contract_Integrated_Accounts__c(
            Account__c = testAcct1.id,
            Contract__c = testContract2.id); 
        cias.add(cia2);
        //Bypass All triggers
        Util.BypassAllTriggers = false;
        
        insert cias;
        
        testMembership1 = [select Id, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
	   
        // Validate Membership Updates
        system.assertEquals(testContract1.id, testMembership1.Earliest_Contract__c);
        //system.assertEquals(testContract2.id, testMembership1.Latest_Contract__c);
        //system.assertEquals(testContract2.id, testMembership1.Active_Contract_Idenfied__c);
        
	test.startTest();  
        delete cias;
	test.stopTest();
        testMembership1 = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id = :testMembership1.id];
        // Validate Membership Updates
        system.assertEquals(testContract1.id, testMembership1.Earliest_Contract__c);
        system.assertEquals(testContract1.id, testMembership1.Latest_Contract__c);
	// DAF - 03-13-12  system.assertEquals(testContract1.id, testMembership1.Active_Contract_Idenfied__c);
    }
	
    //Modified By Dipesh Gupta - Rev Mgmt 606 Production validation failure fixes. 11/08/2017 - used Util.ByPassAllTrigger flag to avoid unwanted code run.
    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields with CIAs
    static testmethod void testCIATriggerMembershipFields()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Util.IsTesting = true;
        
        //Bypass All triggers
        Util.BypassAllTriggers = true;
        
        // INSERT TEST //
        // Create new test Accounts
        list<Account> testaccs = new list<Account>();
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct1);
        Account testAcct2 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct2);
        Account testAcct3 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        testaccs.add(testAcct3);
        insert testaccs;
        
        // Create new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No'); // Create program
        
        insert testProg1;
        
       // Create Memberships
        list<Membership__c> testmems = new list<Membership__c>();
        Membership__c testMembership1 = new Membership__c(
            Name='Test Membership 1', 
            Account_Name__c=testAcct1.id, 
            Program__c=testProg1.id);
        testmems.add(testMembership1);
        Membership__c testMembership2 = new Membership__c(
            Name='Test Membership 2', 
            Account_Name__c=testAcct2.id, 
            Program__c=testProg1.id);
        testmems.add(testMembership2);
        
        insert testmems;
        
        // Create new test Contracts
        list<Contract__c> testcontracts = new list<Contract__c>();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct2.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3000, 
            End__c = System.Today() - 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract2);
        Contract__c testContract3 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct3.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() +1000, 
            End__c = System.Today() + 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract3);
            
        // TEST INSERT //
        // Insert
        insert testcontracts; 
        
        Util.BypassAllTriggers = false;
        //Connect testContract1 to testMembership2
        list<Contract_Integrated_Accounts__c> testcias = new list<Contract_Integrated_Accounts__c>();
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract1.id,
            Account__c = testAcct2.id
            ));
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract3.id,
            Account__c = testAcct2.id
            ));
        insert testcias;
        
        testContract1 = new Contract__c(Id = testContract1.id, Start__c = system.today().addDays(-4));
        testContract3 = new Contract__c(Id = testContract3.id, Name = 'testnameupdate');
        testcontracts = new list<Contract__c>{testContract1, testContract3};
            
	test.startTest();
        update testcontracts;
	test.stopTest();       
       
        testmems = [select Id, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];       
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                system.assertEquals(testContract1.id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract1.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract1.id, mem.Latest_Contract__c);
        
            }
            //reflects testContract1 as well as testContract2 and 3
            if (mem.id == testMembership2.id) {
                system.assertEquals(testContract1.id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract2.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract3.id, mem.Latest_Contract__c);
            }
        }
        
    }
    
	//Modified By Dipesh Gupta - Rev Mgmt 606 Production validation failure fixes. 11/08/2017 - used Util.ByPassAllTrigger flag to avoid unwanted code run.
    // Test updating Contract's status from an 'Active' status to one that is 'Inactive' (pending, closed, void)
    static testmethod void testUpdateContractStatus()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypass All triggers
        Util.BypassAllTriggers = true;
        
        // INSERT TEST //
        // Create new test Accounts
        list<Account> testaccs = new list<Account>();
        Account testAcct1 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct1);
        Account testAcct2 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct2);
        Account testAcct3 = TestUtilities.CreatenewAccount(false);
        testaccs.add(testAcct3);
        insert testaccs;
        
        // Create new test Program for use as the Program on the Contract
        Program__c testProg1 = TestUtilities.CreateNewProgram(false);
        testProg1.Create_memberships__c = 'No';
        insert testProg1;
        
       // Create Memberships
        list<Membership__c> testmems = new list<Membership__c>();
        Membership__c testMembership1 = TestUtilities.CreateNewMembership(testAcct1.Id, testProg1.Id, false);
        testmems.add(testMembership1);
        Membership__c testMembership2 = TestUtilities.CreateNewMembership(testAcct2.Id, testProg1.Id, false);
        testmems.add(testMembership2);
        
        insert testmems;
        
        // Create new test Contracts
        list<Contract__c> testcontracts = new list<Contract__c>();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract1);
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct2.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3000, 
            End__c = System.Today() - 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract2);
        Contract__c testContract3 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct3.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() +1000, 
            End__c = System.Today() + 2000 ,
            Status__c = 'Dropped'
            );
        testcontracts.add(testContract3);
        
        insert testcontracts;
        
        //Connect testContract1 to testMembership2
        list<Contract_Integrated_Accounts__c> testcias = new list<Contract_Integrated_Accounts__c>();
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract1.id,
            Account__c = testAcct2.id
            ));
        testcias.add(new Contract_Integrated_Accounts__c(
            Name = 'testcia',
            Contract__c = testContract3.id,
            Account__c = testAcct2.id
            ));
        insert testcias;
        
        //Bypass All triggers
        Util.BypassAllTriggers = false;
        
        testContract1 = new Contract__c(Id = testContract1.id, Start__c = system.today().addDays(-4), Status__c = 'Pending');
        testContract3 = new Contract__c(Id = testContract3.id, Name = 'testnameupdate');
        testcontracts = new list<Contract__c>{testContract1, testContract3};
            
        test.startTest();  
        update testcontracts;
        test.stopTest();       
       
        testmems = [select Id, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];        
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                system.assertEquals(null, mem.Active_Contract_Idenfied__c);
                system.assertEquals(null, mem.Earliest_Contract__c);
                system.assertEquals(null, mem.Latest_Contract__c);
        
            }
            //reflects testContract1 as well as testContract2 and 3
            if (mem.id == testMembership2.id) {
                system.assertEquals(testContract3.Id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract2.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract3.id, mem.Latest_Contract__c);
            }
        }
    }

    static testmethod void testContractUpdateMembershipFields()
    { 
        //Bypass all Triggers
        Util.BypassAllTriggers = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*  Make sure Membership fields are being set properly */
        //set flags to keep triggers out of the way
        Util.IsTesting = true;
        //Util.IsBatch = true;
        
        list<Account> testaccs = new list<Account>();
        Account a1origPayer = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc1');
        testaccs.add(a1origPayer);
        Account a2newPayer = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc2');
        testaccs.add(a2newPayer);
        Account a3cia = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc3');
        testaccs.add(a3cia);
        insert testaccs;
        
        Contact c = new Contact(LastName = 'test', AccountID = a3cia.id, Email = 'Test'+Math.random()+'@eab.com', 
								Title = 'Test', Phone = '614-555-8855');
        insert c;
        
        Program__c prog = new Program__c(Name = 'testprog');
        insert prog;
        
        list<Membership__c> mems = new list<Membership__c>();
        mems.add(new Membership__c(
            Account_Name__c = a3cia.id,
            Program__c = prog.id,
            Name = 'testmem'
            ));

        insert mems;
        
        list<Contract__c> contracts = new list<Contract__c>();
        
        //Negotiated Amount, Type, Start, End, Year, Program, Join Date, Payer Account, Main Contact, and Invoice Contact
        //three contracts, one for each Account     
        contracts.add(new Contract__c(
            Payer_Account__c = a1origPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-1194),
            End__c = system.today().addDays(-828),
            Year__c = '2010',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a1origPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-829),
            End__c = system.today().addDays(-465),
            Year__c = '2011',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a2newPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-464),
            End__c = system.today().addDays(-99),
            Year__c = '2012',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
            ));
        contracts.add(new Contract__c(
            Payer_Account__c = a2newPayer.id,
            Program__c = prog.id,
            Status__c = 'ATL',
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2013',
            Main_Contact__c = c.id,
            Invoice_Contact__c = c.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = true
            ));
        insert contracts;
        
        //a Contract Integrated Account, previously on Contract with A1, but now on contract with A2, and CIA account = A3 
        //(This will link the A1 Contract to the A2 Membership.)
        contracts = [select Join_Date__c, Active__c, Start__c, Payer_Account__c from Contract__c where id in :contracts];
        List<Contract_Integrated_Accounts__c> lCIAs1 = new list<Contract_Integrated_Accounts__c>();
        List<Contract_Integrated_Accounts__c> lCIAs2 = new list<Contract_Integrated_Accounts__c>();
        Contract__c activeContract;
        for (Contract__c con : contracts) {
            if (con.Payer_Account__c == a1origPayer.id) {
                Contract_Integrated_Accounts__c testcia1 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a3cia.id);
                
                //insert testcia1;
                lCIAs1.add(testcia1);
            }
            else if (con.Payer_Account__c == a2newPayer.id) {
                Contract_Integrated_Accounts__c testcia2 = new Contract_Integrated_Accounts__c(
                    Contract__c = con.id,
                    Account__c = a3cia.id);
                
                //insert testcia2;
                lCIAs2.add(testcia2);
            }
            if(con.Active__c == true){
                activeContract = con;
            }
        }
        
        //Enable all Triggers
        Util.BypassAllTriggers = false;
        
        insert lCIAs2;
        insert lCIAs1;
        
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
        
        mems = [select Join_Date_Most_Recent__c, Account_Name__c, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c 
            from Membership__c where id in :mems];
        for (Membership__c mem : mems) {
	}
    }   
	
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
    static testmethod void testCreateMembershipForCIA(){
    	
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Util.IsTesting = true;
        Util.IsTestingContractIntegratedAcct = true;

	Util.ByPassAllTriggers = true;
        
        //List to hold account records
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'testacct1', Account_Formal_Name__c = 'testacct1'));
        accounts.add(new Account(Name = 'testacct2', Account_Formal_Name__c = 'testacct2'));
        accounts.add(new Account(Name = 'testacct3', Account_Formal_Name__c = 'testacct3'));
        
        //Insert Account records
        insert accounts;
        
        //List to hold program records
        list<Program__c> programs = new list<Program__c>();
        
        //Add record in list
        for (Integer i = 0; i < 3; i++) {
            programs.add(new Program__c(Name = 'testprog' + i, Program_Acronym__c = 'TEST' + i));
        }
        
        //Insert Program records
        insert programs;
        
        Product2 pdct = TestUtilities.createNewProduct(programs[0].Id, true);
        
        list<Contract__c> contracts = new list<Contract__c>();
        
        contracts.add(new Contract__c(
            Name='Test Contract1',
            Payer_Account__c = accounts[0].Id,
            Program__c = programs[0].Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped'));
        
        contracts.add(new Contract__c(
            Name='Test Contract2',
            Payer_Account__c = accounts[0].Id,
            Program__c = programs[1].Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped'));
            contracts.add(new Contract__c(
            Name='Test Contract3',
            Payer_Account__c = accounts[0].Id,
            Program__c = programs[1].Id,
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3,
            Year__c = String.valueOf(system.today().Year()),
            Status__c = 'Dropped'));
           
        insert contracts;
        
        //Creating the 2 contract data
        Contract stCon1 = TestUtilities.createNewStandardContract(accounts[0].Id, false);
        Contract stCon2 = TestUtilities.createNewStandardContract(accounts[0].Id, false);
        List<Contract> standardContracts = new List<Contract>{stCon1, stCon2};
        
        //Inserting the Data of Contract Records 
        insert standardContracts;
        
		Util.ByPassAllTriggers = false;
		
        test.startTest();
        
        //List To populate CIA records
        list<Contract_Integrated_Accounts__c> CIARecords = new list<Contract_Integrated_Accounts__c>();
        
        //Add CIA records in list
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id,Contract__c = contracts[0].id, LOA_Contract__c = standardContracts[1].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[1].id,Contract__c = contracts[1].id, LOA_Contract__c = standardContracts[1].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id,Contract__c = contracts[0].id, LOA_Contract__c = standardContracts[1].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[1].id,Contract__c = contracts[1].id, LOA_Contract__c = standardContracts[1].Id));
        
        //Insert
        insert CIARecords;
    }
    //Added By - Abhisekh Mishra - 06/28/2021 - CR-20210517-15151 - To increase code coverage
    //Test method for populateSubscriptionFieldsOnMembership method in ContactIntegratedAccountsTriggerHelper class
    static testmethod void testPopulateSubscriptionFieldsOnMembership()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.IsTestingContractIntegratedAcct = true;
		
        //Disabling code coverage
	Util.ByPassAllTriggers = true;
        
        //start Testing
        //test.startTest();
        
        //List to hold account records
        List<Account> accounts = new List<Account>();
        
        //Add account records into the list
        accounts.add(new Account(Name = 'testacct1', Account_Formal_Name__c = 'testacct1'));
        accounts.add(new Account(Name = 'testacct2', Account_Formal_Name__c = 'testacct2'));
        accounts.add(new Account(Name = 'testacct3', Account_Formal_Name__c = 'testacct3'));
        
        //Insert Account records
        insert accounts;
        
        //Creating the contract data
        Contract stCon1 = TestUtilities.createNewStandardContract(accounts[0].Id, false);
        Contract stCon2 = TestUtilities.createNewStandardContract(accounts[1].Id, false);
        Contract stCon3 = TestUtilities.createNewStandardContract(accounts[2].Id, false);
        
        //List to add contract data
        List<Contract> standardContracts = new List<Contract>{stCon1, stCon2, stCon3};
        
        //Inserting the Data of Contract Records 
        insert standardContracts;
        
        //List to hold program records
        list<Program__c> programs = new list<Program__c>();
        
        //Add record in list
        for (Integer i = 0; i < 3; i++) {
            programs.add(new Program__c(Name = 'testprog' + i, Program_Acronym__c = 'TEST' + i));
        }
        
        //Insert Program records
        insert programs;
       
       //List to hold memberships records        
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Add membership records into the list
        memberships.add(new Membership__c(Name = 'Test Membership One', Account_Name__c = accounts[0].Id, Program__c = programs[0].Id)); 
	memberships.add(new Membership__c(Name = 'Test Membership Two', Account_Name__c = accounts[1].Id, Program__c = programs[1].Id));  
        memberships.add(new Membership__c(Name = 'Test Membership Three', Account_Name__c = accounts[2].Id, Program__c = programs[2].Id));  
        
        //insert membership record 
        if(!Test.isRunningTest())
          insert memberships;
        
	//Get Record Type of Program Subscription
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program'); 
        
        //List to hold subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Add subscription records into the list
        subscriptions.add(new SBQQ__Subscription__c(Program__c = programs[0].Id, SBQQ__Contract__c = standardContracts[0].Id, SBQQ__Account__c = accounts[0].Id,  SBQQ__SubscriptionStartDate__c = System.Today().addDays(1),  SBQQ__SubscriptionEndDate__c = System.Today().addDays(3), SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
        					    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, Membership__c = memberships[0].Id,
                                      		    Status__c = 'Committed', recordTypeId = subscriptionProgramRecordType));
       
        subscriptions.add(new SBQQ__Subscription__c(Program__c = programs[1].Id, SBQQ__Contract__c = standardContracts[1].Id, SBQQ__Account__c = accounts[1].Id,  SBQQ__SubscriptionStartDate__c = System.Today().addDays(2),  SBQQ__SubscriptionEndDate__c = System.Today().addDays(4), SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
        					    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 1, SBQQ__ProrateMultiplier__c = 2, Membership__c = memberships[1].Id,
                                      		    Status__c = 'Committed', recordTypeId = subscriptionProgramRecordType));
        
        subscriptions.add(new SBQQ__Subscription__c(Program__c = programs[2].Id, SBQQ__Contract__c = standardContracts[2].Id, SBQQ__Account__c = accounts[2].Id,  SBQQ__SubscriptionStartDate__c = System.Today().addDays(3),  SBQQ__SubscriptionEndDate__c = System.Today().addDays(5), SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
                                      		    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, Membership__c = memberships[2].Id,
                                      		    Status__c = 'Committed', recordTypeId = subscriptionProgramRecordType));
        
        
        //insert program subscription records
        insert subscriptions;
        
        //Fetch soql to get program subscription records
        subscriptions = [Select Id, Program__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Status__c From SBQQ__Subscription__c
    											   Where RecordType.DeveloperName = 'Program'
    											   AND Program__c != null];
        
        //Assert to check program subscription records
        System.assertEquals(3,  subscriptions.size());
        
        //populate Active, Earliest, Latest subscription fields of subscription record
        memberships[0].Active_Subscription__c = subscriptions[0].Id;
        memberships[0].Earliest_Subscription__c = subscriptions[0].Id;
        memberships[0].Latest_Subscription__c = subscriptions[0].Id;

        //update membership record 
        if(!Test.isRunningTest())
           update memberships;
        	
        //Set to hold Program subscription Ids
        Set<Id> setProgramSubIds = new Set<Id>();
        setProgramSubIds.add(subscriptions[0].Id);
        setProgramSubIds.add(subscriptions[1].Id);
        setProgramSubIds.add(subscriptions[2].Id);
        
        //start Testing
        Test.startTest();
       
        //Disabling Triggers
        Util.ByPassAllTriggers = false;
        
	//List To populate Contract Integration Account records
        list<Contract_Integrated_Accounts__c> CIARecords = new list<Contract_Integrated_Accounts__c>();
        
        //Add CIA records in list
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id, LOA_Contract__c = standardContracts[0].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[1].id, LOA_Contract__c = standardContracts[1].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[1].id, LOA_Contract__c = standardContracts[1].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[2].id, LOA_Contract__c = standardContracts[2].Id));
        
        //Insert Contract Integration Account records
        insert CIARecords;       
        
        //update contract and account field of Contract Integration Account records
        CIARecords[1].Account__c = accounts[2].Id;
        CIARecords[1].LOA_Contract__c = standardContracts[2].Id;
        CIARecords[3].LOA_Contract__c = standardContracts[2].Id;
        update CIARecords;
        
        //Added By - Shalu Sharma - 07/27/2021 - CR-20210621-15227
        List<Contract_Integrated_Accounts__c> updatedContractIntegratedAccts = [SELECT ID, Account__c, LOA_Contract__c FROM Contract_Integrated_Accounts__c];
        System.assertEquals(accounts[2].Id, updatedContractIntegratedAccts[1].Account__c);
        System.assertEquals(standardContracts[2].Id, updatedContractIntegratedAccts[1].LOA_Contract__c);
		     
        //Set to hold Account Ids that has to be deleted
        Set<Id> setDeleteCIAAccIds = new Set<Id>();
	setDeleteCIAAccIds.add(CIARecords[2].Account__c); 
        
        //Set to hold Program Ids
        Set<Id> setProgramIds = new Set<Id>();
	setProgramIds.add(programs[0].Id);
        setProgramIds.add(programs[1].Id);
        setProgramIds.add(programs[2].Id);
        
        //Delete Contract Integration Account record
        delete CIARecords[2];
        
        //Added By - Shalu Sharma - 07/27/2021 - CR-20210621-15227
        List<Contract_Integrated_Accounts__c> contractIntegratedAccts = [SELECT ID FROM Contract_Integrated_Accounts__c];
        System.assertEquals(3, contractIntegratedAccts.size());
       
        Test.stopTest();
        
    } 
    //Added By - Abhisekh Mishra - 06/28/2021 - CR-20210517-15151
    //Modified By - Shalu Sharma - 07/27/2021 - CR-20210621-15227
    //Test method for createMemberships method in ContactIntegratedAccountsTriggerHelper class
    static testmethod void testCreateMemberships()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.IsTestingContractIntegratedAcct = true;

        //Disabling code coverage
		Util.ByPassAllTriggers = true;
        
        //start Testing
        //Test.startTest();
        
        //List to hold account records
        List<Account> accounts = new List<Account>();
        
        //Add account records into the list
        accounts.add(new Account(Name = 'testacct1', Account_Formal_Name__c = 'testacct1'));
        accounts.add(new Account(Name = 'testacct2', Account_Formal_Name__c = 'testacct2'));
        accounts.add(new Account(Name = 'testacct3', Account_Formal_Name__c = 'testacct3'));
        
        //Insert Account records
        insert accounts;
        
        //Creating the 2 contract data
        Contract stCon1 = TestUtilities.createNewStandardContract(accounts[0].Id, false);
        Contract stCon2 = TestUtilities.createNewStandardContract(accounts[0].Id, false);
        
        //List to hold standard contract records
        List<Contract> standardContracts = new List<Contract>{stCon1, stCon2};
        
        //Inserting the Data of Contract Records 
        insert standardContracts;
        
	//List to hold program records
        list<Program__c> programs = new list<Program__c>();
        
        //Add record in list
        for (Integer i = 0; i < 3; i++) {
            programs.add(new Program__c(Name = 'testprog' + i, Program_Acronym__c = 'TEST' + i));
        }
        
        //Insert Program records
        insert programs;

	//Insert product record         
        Product2 pdct = TestUtilities.createNewProduct(programs[0].Id, true);
        
        //List to hold membership records 
        List<Membership__c> memberships = new List<Membership__c>(); 
        
        //Add membership record into the list
        memberships.add(new Membership__c(Name = 'Test Membership One', Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));         
        
        //insert membership record 
        if(!Test.isRunningTest())
          insert memberships;
        
        //Get Record Type of Program subscription 
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program'); 
        
        //List to hold program subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Add program subscription records into the list
        subscriptions.add(new SBQQ__Subscription__c(Program__c = programs[0].Id, SBQQ__Product__c = pdct.Id, SBQQ__Contract__c = standardContracts[0].Id, SBQQ__Account__c = accounts[0].Id,  SBQQ__SubscriptionStartDate__c = System.Today().addDays(1),  SBQQ__SubscriptionEndDate__c = System.Today().addDays(3), SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
        					    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, Membership__c = memberships[0].Id,
                                      		    Status__c = 'Committed', recordTypeId = subscriptionProgramRecordType));
        subscriptions.add(new SBQQ__Subscription__c(Program__c = programs[0].Id, SBQQ__Product__c = pdct.Id, SBQQ__Contract__c = standardContracts[0].Id, SBQQ__Account__c = accounts[0].Id,  SBQQ__SubscriptionStartDate__c = System.Today().addDays(1),  SBQQ__SubscriptionEndDate__c = System.Today().addDays(3), SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
                                      		    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 3, /*Membership__c = memberships[0].Id,*/
                                      		    Status__c = 'Committed', recordTypeId = subscriptionProgramRecordType));
        
        //insert program subscription records
        insert subscriptions;

        //Fetch program subscription records
	subscriptions = [Select Id, Program__c, SBQQ__Product__r.Program__c, SBQQ__Contract__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' AND SBQQ__Product__r.Program__c != null];       
        System.assert(subscriptions.size()>0);
        
        //Enabling Trigger
        Util.ByPassAllTriggers = false;
        
        //Start Testing
        Test.startTest();
        
        //List To populate CIA records
        list<Contract_Integrated_Accounts__c> CIARecords = new list<Contract_Integrated_Accounts__c>();
        
        //Add CIA records in list
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id, LOA_Contract__c = standardContracts[0].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id, LOA_Contract__c = standardContracts[0].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id, LOA_Contract__c = standardContracts[0].Id)); 
        CIARecords.add(new Contract_Integrated_Accounts__c(Account__c = accounts[0].id, LOA_Contract__c = standardContracts[0].Id));
        
        //Insert CIA records
        insert CIARecords;  
        
        Test.stopTest();
        
        memberships = [Select Id, Account_Name__c, Program__c, Membership_Status_Text__c From Membership__c];
        System.assertEquals(accounts[0].Id, memberships[0].Account_Name__c);
        //Added By - Shalu Sharma - 07/27/2021 - CR-20210621-15227 
        System.assertEquals(programs[0].Id, memberships[0].Program__c);
        System.assert(memberships[0].Membership_Status_Text__c != null);
    }
}