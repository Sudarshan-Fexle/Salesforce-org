//Modified By - Deepak Kumawat - Apollo Release Test Fixed Failures
//Modified By - Rajeev jain - 11/08/2017 - Fixed too many soql error(While Rev Mgmt 606 deployment to Prod)- testAIAUMembershipActiveContractfieldswithCIAs, testAIAUMembershipActiveContractfieldswithCIAs_Deleted
@isTest(seeAllData=false)
private class TestContract_UpdateFields
{
    
	//Modified By - Rajeev jain - 11/08/2017 - Fixed too many soql error - Applied by pass logic and changed start and stop position
    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testAIAUMembershipActiveContractfieldswithCIAs()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testMembershipActiveContractfields ###');
        
        Util.IsTesting = true;
        
	//Applying bypass Trigger to by pass trigger for unrelavent data insert
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
        
        test.startTest();
        
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
        
		Util.BypassAllTriggers = false;
		
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
            
		
		system.debug('\n\n184 withcias update')   ;    
        update testcontracts;
		test.stopTest();       
       
        testmems = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];
		system.debug('\n\ntestMembership1 ' + testMembership1);         
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
        
		System.Debug('### TESTMETHOD END testAIAUMembershipActiveContractfields ###');
    }
    
	//Modified By - Rajeev jain - 11/08/2017 - Fixed too many soql error - Applied by pass logic and changed start and stop position
    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields
    static testmethod void testAIAUMembershipActiveContractfieldswithCIAs_Deleted()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testMembershipActiveContractfields ###');
        
        Util.IsTesting = true;
        
		//Applying bypass Trigger to by pass trigger for unrelavent data insert
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
		
        test.startTest();
        
	//Applying bypass Trigger to by pass trigger for unrelavent data insert
	Util.BypassAllTriggers = false;
		
        // Create new test Contracts
        list<Contract__c> testcontracts = new list<Contract__c>();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3, 
            End__c = System.Today() + 3 ,
            Status__c = 'ATL'
            );
        testcontracts.add(testContract1);
        
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct2.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() - 3000, 
            End__c = System.Today() - 2000 ,
            Status__c = 'ATL'
            );
        testcontracts.add(testContract2);
        
        Contract__c testContract3 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct3.Id, 
            Program__c = testProg1.Id, 
            Start__c = System.Today() +1000, 
            End__c = System.Today() + 2000 ,
            Status__c = 'ATL'
            );
        
        testcontracts.add(testContract3);

        // Insert
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
        
        test.stopTest(); 
        
        testContract1 = new Contract__c(Id = testContract1.id, Start__c = system.today().addDays(-4));
        testContract3 = new Contract__c(Id = testContract3.id, Name = 'testnameupdate');
        testcontracts = new list<Contract__c>{testContract1, testContract3};
		system.debug('\n\n184 withcias update')   ;    
        update testcontracts;

        delete testcias[0];
		
		
        //update testcontracts;
		      
        testmems = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id IN :testmems];
		system.debug('\n\ntestMembership1 ' + testMembership1);
        
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                //system.assertEquals(null, mem.Active_Contract_Idenfied__c);
                //system.assertEquals(null, mem.Earliest_Contract__c);
                //system.assertEquals(null, mem.Latest_Contract__c);
        
            }
            //reflects testContract1 as well as testContract2 and 3
            if (mem.id == testMembership2.id) {
                //system.assertEquals(testContract3.Id, mem.Active_Contract_Idenfied__c);
                //system.assertEquals(testContract2.Id, mem.Earliest_Contract__c);
                //system.assertEquals(testContract3.Id, mem.Latest_Contract__c);
            }
        }
        
		System.Debug('### TESTMETHOD END testAIAUMembershipActiveContractfields ###');
    }

    // Test updating Membership's Earliest Contract, Latest Contract, and Active Contract Identified fields with Contract Integrated Account connections also
    static testmethod void testAIAUMembershipActiveContractfieldsnoCIAs()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testMembershipActiveContractfieldswithCIAs ###');
        
        Util.IsTesting = true;
        
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
		test.startTest();
        insert testcontracts;
		test.stopTest();       
       
        testmems = [select Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c from Membership__c where id in :testmems];
		system.debug('\n\ntestMembership1 ' + testMembership1);         
        for (Membership__c mem : testmems) {
            if (mem.id == testMembership1.id) {
                system.assertEquals(testContract1.id, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract1.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract1.id, mem.Latest_Contract__c);
        
            }
            if (mem.id == testMembership2.id) {
                system.assertEquals(null, mem.Active_Contract_Idenfied__c);
                system.assertEquals(testContract2.id, mem.Earliest_Contract__c);
                system.assertEquals(testContract2.id, mem.Latest_Contract__c);
            }
        }
        
		System.Debug('### TESTMETHOD END testAIAUMembershipActiveContractfields ###');
    }
	
    // Test setting the name for new/updated Contracts based on: Payer Account Name, Program Acronym, and Start Year.
    static testmethod void Contract_BIBU_UpdateFields_NameUpdate()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN Contract_BIBU_UpdateFields_NameUpdate ###');
        
        Util.IsTesting = true;
        Util.bypassAllTriggers = true;

        // INSERT TEST //
        // Create a new test Account for use as the Payer Account on the Contract
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        insert testAcct1;
        
        testAcct1 = [select Id, Name from Account where Id = :testAcct1.Id];
        
        // Create a new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No'); // Create program
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No'); // Create program
        
        insert testProg1;
        insert testProg2;
        
        testProg1 = [select Id, Program_Acronym__c from Program__c where Id = : testProg1.Id];
        testProg2 = [select Id, Program_Acronym__c from Program__c where Id = : testProg2.Id];
        
        // Create a new test Contact for use as the Invoice Contact and Main Contact on the Contract
        Contact testContact1 = new Contact(FirstName='Test', LastName='Trigger_User', AccountId=testAcct1.id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        Contact testContact2 = new Contact(FirstName='Test', LastName='Trigger_User', AccountId=testAcct1.id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert testContact1;
        insert testContact2;

        
        // Create a new test Contract
        Contract__c testContract = new Contract__c(Name='Test Contract', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, Main_Contact__c = testContact1.Id, 
            Invoice_Contact__c = testContact2.Id, Start__c = System.Today(), Year__c = String.valueof(System.Today().Year()), Type__c = 'NBB');
        
        //Flag to not bypass Triggers
        Util.byPassAllTriggers = False;
         
        insert testContract;
        
        //Flag to bypass Triggers
        Util.byPassAllTriggers = True;
        System.Debug('### Test Contract Id: ' + testContract.Id + ' ###');        
        
        
        // Set the name to compare against
        string tmpName1 = testAcct1.Name + ' - ' + testProg1.Program_Acronym__c + ' - ' + testContract.Year__c;
        
        System.Debug('### Contract Name should be: ' + tmpName1 + ' ###'); 
        
        // Retrieve the Contract record that was inserted as a test
        Contract__c updatedContract = [select id, Name, Program__c, Payer_Account__c from Contract__c where id = :testContract.Id];
        System.Debug('### Contract Name is: ' + updatedContract.Name + ' ###'); 

        // Confirm the name matches the name in the tmpName variable
        //System.assertEquals(tmpName1, updatedContract.Name);
        

        // TEST UPDATE //
        // Program Change
        testContract.Program__c = testProg2.Id;
		test.startTest();        

        //Flag to not bypass Triggers
        Util.byPassAllTriggers = False;
        
        update testContract;
        
        //Flag to bypass Triggers
        Util.byPassAllTriggers = True;
        
        // Set the name to compare against
        string tmpName2 = testAcct1.Name + ' - ' + testProg2.Program_Acronym__c + ' - ' + testContract.Year__c;
        
        System.Debug('### Contract Name should be: ' + tmpName2 + ' ###'); 
        
        // Retrieve the Contract record that was inserted as a test
        updatedContract = [select id, Name, Program__c, Payer_Account__c from Contract__c where id = :testContract.Id];
        System.Debug('### Contract Name is: ' + updatedContract.Name + ' ###'); 

        // Confirm the name matches the name in the tmpName variable
        //System.assertEquals(tmpName2, updatedContract.Name);
        
        
        // Start Date Change //
        testContract.Start__c = System.Today() - 1;
        
        //Flag to not bypass Triggers
        Util.byPassAllTriggers = False;
        
        update testContract;
        
        //Flag to bypass Triggers
        Util.byPassAllTriggers = True;
        
		test.stopTest();      
        // Set the name to compare against
        string tmpName3 = testAcct1.Name + ' - ' + testProg2.Program_Acronym__c + ' - ' + testContract.Year__c;
        
        System.Debug('### Contract Name should be: ' + tmpName2 + ' ###'); 
        
        // Retrieve the Contract record that was inserted as a test
        updatedContract = [select id, Name, Program__c, Payer_Account__c from Contract__c where id = :testContract.Id];
        System.Debug('### Contract Name is: ' + updatedContract.Name + ' ###'); 

        // Confirm the name matches the name in the tmpName variable
        //System.assertEquals(tmpName3, updatedContract.Name);
        
        System.Debug('### TESTMETHOD END Contract_BIBU_UpdateFields_NameUpdate ###');
    }
    
	/* Testing Contract_BIBU_UpdateFields.trigger now   */
        
    // Test Program Business Line update on Contract (Field 'Business Line From Trigger')
    static testmethod void Contract_BIBU_UpdateFields_BusinessLineUpdate()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN Contract_BIBU_UpdateFields_BusinessLineUpdate ###');
        
        Util.IsTesting = true;
        Util.bypassAllTriggers = true;
        
        // INSERT TEST //
        // Create a new test Account for use as the Payer Account on the Contract
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        insert testAcct1;
        
        // Create a new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'RI');
        
        insert testProg1;
        insert testProg2;
        
        // Create a new test Contact for use as the Invoice Contact and Main Contact on the Contract
        Contact testContact1 = new Contact(FirstName='Test', LastName='Trigger_User', AccountId=testAcct1.id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        
        insert testContact1;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create a new test Opportunity for use as the Source Contract on the Contract
        Opportunity testOpp1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp1',Main_Contact__c = testContact1.Id, AccountId=testAcct1.Id, Amount=1, CloseDate=(System.Today() + 1), StageName='Pending');
        
        insert testOpp1;
        
        // Create a new test Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, Main_Contact__c = testContact1.Id, 
            Invoice_Contact__c = testContact1.Id, Start__c = System.Today(), Year__c = String.valueof(System.Today().Year()), Type__c = 'NBB'
            , Source_Opportunity__c=testOpp1.Id
            );
            
        System.Debug('### Test Contract Id: ' + testContract1.Id + ' ###');
		test.StartTest();        
        
        //Flag to not bypass Triggers
        Util.byPassAllTriggers = False;
        // Insert Test
        insert testContract1;
        
        testContract1 = [select Id, Program__c, Business_Line_From_Trigger__c from Contract__c where Id = :testContract1.Id];
        
        //System.AssertEquals(testProg1.Business_line__c, testContract1.Business_Line_From_Trigger__c);
        // Update Test
        testContract1.Program__c = testProg2.Id;
        
        update testContract1;
        
        //Flag to bypass Triggers
        Util.byPassAllTriggers = True;
        
		test.StopTest();
        
        testContract1 = [select Id, Program__c, Business_Line_From_Trigger__c from Contract__c where Id = :testContract1.Id];
        
        //System.AssertEquals(testProg2.Business_line__c, testContract1.Business_Line_From_Trigger__c);
                        
        System.Debug('### TESTMETHOD END Contract_BIBU_UpdateFields_BusinessLineUpdate ###');
    }

     static testmethod void testActiveinsert() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // INSERT TEST //
        // Create a new test Account for use as the Payer Account on the Contract
        Recordtype rt = [select id from Recordtype where SObjectType = 'Account' and Name = 'Other' limit 1];
        
        Account testAcct1 = new Account(RecordTypeId=rt.id, Name='Test Trigger Account1', 
                                        Account_Formal_Name__c='Test Trigger Account1', 
                                        Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); 
        
        // Create account of 'Other' record Type
        insert testAcct1;
         
         // Test Class Fix Start Here 13Feb By: Dipesh Gupta
         //Creating Contact record 
         Contact cont = TestUtilities.CreateNewContact(True);
         // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        
        // Create a new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'RI');
        insert testProg1;
        insert testProg2;
        
        // Create a new test Opportunity for use as the Source Contract on the Contract
        rt = [select id from Recordtype where SObjectType = 'Opportunity' and Name = 'RI Marketing' limit 1];
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity testOpp1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId=rt.id, Name='Test Opp1', AccountId=testAcct1.Id,Main_Contact__c = cont.Id, 
                                               Amount=1, CloseDate=(System.Today() + 1), StageName='Pending');
        
        insert testOpp1;
        
        // Create 2 new test Contracts
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355)
            );
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(10), End__c = system.today().addDays(375)
            );
        
        list<Contract__c> testcontracts = new list<Contract__c>{testContract1, testContract2};
        
        //Start Test from here
        test.StartTest();     
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        // Insert Test
        insert testcontracts;

        //Stop Test here    
        test.StopTest();
        
        testContracts = [select Id, Start__c, Active__c from Contract__c where Id in :testcontracts];
        
        for (Contract__c con : testcontracts) {
            if (con.Start__c < system.today()) system.AssertEquals(True, con.Active__c);
            if (con.Start__c > system.today()) system.AssertEquals(False, con.Active__c);
        }
    }
    
    static testmethod void testActiveupdate()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testActiveupdate (BIBU)###');
        
        Util.IsTesting = true;
        
        // INSERT TEST //
        // Create a new test Account for use as the Payer Account on the Contract
        Recordtype rt = [select id from Recordtype where SObjectType = 'Account' and Name = 'Other' limit 1];
        Account testAcct1 = new Account(RecordTypeId=rt.id, Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', 
            Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        insert testAcct1;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        
        // Create a new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ1', Create_memberships__c='No', Business_line__c = 'RI');
        
        insert testProg1;
        insert testProg2;
        
        test.StartTest(); 
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create a new test Opportunity for use as the Source Contract on the Contract
        rt = [select id from Recordtype where SObjectType = 'Opportunity' and Name = 'RI Marketing' limit 1];
        Opportunity testOpp1 = new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId=rt.id, Name='Test Opp1', Main_Contact__c = cont.Id, AccountId=testAcct1.Id, Amount=1, CloseDate=(System.Today() + 1), StageName='Pending');
        
        insert testOpp1;
        
        
        // Create 2 new test Contracts
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355)
            );
        Contract__c testContract2 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(10), End__c = system.today().addDays(375)
            );
            
        System.Debug('### Test Contract Id: ' + testContract1.Id + ' ###');
        
        list<Contract__c> testcontracts = new list<Contract__c>{testContract1, testContract2};
        // Insert Test
        insert testcontracts;
        
        testContracts = [select Id, Start__c, Active__c from Contract__c where Id in :testcontracts];
        
        for (Contract__c con : testcontracts) {
            if (con.Start__c < system.today()) {
                system.AssertEquals(True, con.Active__c);
                //Make this inactive now
                con.Start__c = system.today().addDays(100);
            }
            if (con.Start__c == system.today().addDays(10)) {
				system.debug('\n\n473 con ' + con);
                system.AssertEquals(False, con.Active__c);
            }
        }
     
        update testContracts;
        
		test.StopTest();
       
        testContracts = [select Id, Start__c, Active__c from Contract__c where Id in :testcontracts];
        for (Contract__c con : testcontracts) {
			system.debug('\n\n485 con ' + con);         
            system.assertEquals(False, con.Active__c);
        }
        
        System.Debug('### TESTMETHOD END testActiveupdate ###');
    }
    
    // Test Join date come over from previous contract on source opportunity
    static testmethod void testJoinDate()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        System.Debug('### TESTMETHOD BEGIN testJoinDate ###');
        
        Util.IsTesting = true;
        
        // INSERT TEST //
        // Create a new test Account for use as the Payer Account on the Contract
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        insert testAcct1;
        
        testAcct1 = [select Id, Name from Account where Id = :testAcct1.Id];
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = testAcct1.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        
        // Create a new test Program for use as the Program on the Contract
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', Program_Acronym__c='ZZZ', Create_memberships__c='No'); // Create program
        insert testProg1;
        
        testProg1 = [select Id, Program_Acronym__c from Program__c where Id = : testProg1.Id];
        
        // Create a new Previous Contract
        Contract__c testContractprev = new Contract__c(
            Name='Test Contract', Payer_Account__c = testAcct1.Id, Program__c = testProg1.Id,
            Start__c = System.Today(), Year__c = String.valueof(System.Today().Year()), Type__c = 'Renewal',
            Join_Date__c = system.today().addYears(-1)
            );
        
        test.StartTest();
        
        insert testContractprev;
        
	string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();

	//Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create a new test Opportunity for use as the Source Opp on the Contract
        Opportunity testOpp1 = new Opportunity(
            Name='Test Opp1', AccountId=testAcct1.Id, 
            Amount=1, CloseDate=(System.Today() + 1), 
            StageName='Pending',Sales_Pursuit_Products__c = 'APS',
            Main_Contact__c = cont.Id,
            Previous_Contract__c = testContractprev.id, RecordTypeId = recordTypeId);
        
        insert testOpp1;
        
        testOpp1 = [select Id, Name, Amount, Previous_Contract__r.Join_Date__c from Opportunity where Id = :testOpp1.Id];
        
        // Create a new test Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract', 
            Payer_Account__c = testAcct1.Id, 
            Program__c = testProg1.Id,
            Start__c = System.Today(), 
            Year__c = String.valueof(System.Today().Year()), 
            Type__c = 'Renewal',
            Source_Opportunity__c=testOpp1.Id
            );
        
        insert testContract1;
        
		test.StopTest();        
        System.Debug('### Test Contract Id: ' + testContract1.Id + ' ###');
        
        testContract1 = [select Id, Join_Date__c, Source_Opportunity__r.Previous_Contract__r.Join_Date__c from Contract__c where Id = :testContract1.Id];
        
        System.AssertEquals(testContract1.Source_Opportunity__r.Previous_Contract__r.Join_Date__c, testContract1.Join_Date__c);
                        
        System.Debug('### TESTMETHOD END testJoinDate ###');
    }
    
    private static testmethod void deleteCIA()
    {
        Contract_Integrated_Accounts__c cia = new Contract_Integrated_Accounts__c(Name = 'testcia');
        insert cia;
        String contractIntegratedAccountsId = cia.id;
        delete cia;
        try
        {
            Contract_Integrated_Accounts__c mathcingContactIntegratedAcct = [select id 
                                                                             from Contract_Integrated_Accounts__c 
                                                                             where id=:contractIntegratedAccountsId];
            System.assert(false,'The record was not sucessfully deleted.');
        }
        catch(System.QueryException e)
        {
            System.assert(true);
        }                                                                
    }
    
    // bypass "Status_ATL_or_Honorary_Require_Fields" validation rule on contracts who started before 3/24/11
    private static testmethod void bypassStatus_ATL_or_Honorary_Require_FieldsValidation()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        // Create a new test Account for use as the Payer Account on the Contract
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        //Insert the account
        insert testAcct1;
        
        Profile nonSysAdmin = [select id from Profile where name = 'ABC Dataloader' limit 1];
        User u = [select id, Entity__c from User
                  where isActive = true
                  and Entity__c != null
                  and ProfileId=:nonSysAdmin.id limit 1];
       
        System.runAs(u)
        { 
            Contract__c contract = TestUtilities.CreateNewContract(false);
            contract.Status__c = 'ATL';
            contract.Negotiated_Amount__c = null;
            contract.Start__c = Date.newInstance(2011,3,23);
            contract.Payer_Account__c = testAcct1.Id;
            insert contract;
            System.assertNotEquals(null,contract.id);
            Contract__c contractUpdate = [select id, Status__c from Contract__c where id =: contract.id];
            contractUpdate.status__c = 'Honorary';
            try
            {
                update contractUpdate;
                System.assert(true);
            }
            catch(System.DmlException e)
            {
                System.assert(false,e.getMessage());    
            }
        }
    }
    
     // do not bypapss "Status_ATL_or_Honorary_Require_Fields" validation rule on contracts who started before 3/24/11
    private static testmethod void doNOTbypassStatus_ATL_or_Honorary_Require_FieldsValidation()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        // Create a new test Account for use as the Payer Account on the Contract
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); // Create account of 'Other' record Type
        
        //Insert the account
        insert testAcct1;
        
        Profile nonSysAdmin = [select id from Profile where name = 'ABC Dataloader' limit 1];
        User u = [select id, Entity__c from User
                  where isActive = true
                  and Entity__c != null
                  and ProfileId=:nonSysAdmin.id limit 1];
        
        System.runAs(u)
        { 
            Contract__c contract = TestUtilities.CreateNewContract(false);
            contract.Status__c = 'ATL';
            contract.Negotiated_Amount__c = null;
            contract.Type__c = null;
            contract.Start__c = Date.newInstance(2011,3,24);
            contract.End__c = null;
            contract.Year__c = null;
            contract.Program__c = null;
            contract.Join_Date__c = null;
            contract.Main_Contact__c = null;
            contract.Invoice_Contact__c = null;
            contract.Payer_Account__c = testAcct1.Id;
            
            try
            {
                insert contract;
                System.assert(false);
            }
            catch(System.DmlException e)
            {
                if(e.getMessage().contains('When status is ATL or Honorary the following fields are required'))
                {
                    System.assert(true);    
                }
                else
                {
                    System.assert(false,e.getMessage());    
                }
            }
        }
    }
}