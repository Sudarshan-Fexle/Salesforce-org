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
@isTest
private class TestContractOpp_Ext {
/*
	Purpose:           Ensure 100% Test Coverage for Visualforce Controller ContractOpp_Ext

	Create By:  	   Jeremy Nottingham (Synaptic) 11/2010

	Last Modified By:  Rajeev Jain 12/07/2015

	Current Version:    V1.6

	Revision Log:       V1.0 - Created - (JN) Created Class along with original ContractOppExt and VF page ContractOppCreator
	                    V1.1 - Modified By - (JN) Added this header 1/26/11
				 - Included Main Contact validation
				 - commented and ensured 100% coverage
			    V1.2 - Modified By - (NB-2011-03-24) Modified code to allow for deployment
				 - Removed queries referencing data that may not exist and created records through test (no records will actually be committed and are used via the test method only)
				 - Added try/catch blocks where necessary for RecordType queries
				 - Removed assertion tests (best practice would be to readd these after deployment, but that will need to wait until data has been loaded into the system)
				 - Confirmed 98% code coverage (loss in coverage was due to removal of assertions) 
			    V1.3 - Modified By -  (VH-2012-03-06) Un-did NB's changes so that the unit tests now actually test functionality
			    	 - Included the use of TestUtilities class to simplify the code a bit
			    V1.4 - (SUNJ 12/19/13) - CR-20130118-2218
			    V1.5 - Modified By - (VH 8/6/15) - CR-20150414-8871 - added test to verify edge case where there is no opportunity related to the contract
			    V1.6 - Modified By - Rajeev Jain 12/07/2015 - CR-20151202-9434 - Increased code coverage  
			    V1.7 - Modified By - Rajeev Jain - 09/04/2020 - CR-20200217-13756 - (As per CR Delete the RecordType )
                    	    V1.8 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
*/
    static testmethod void testCoreContractOppExt() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype 
                   where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            Sales_Pursuit_Products__c  = 'APS',
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
        );
        insert testcon;
        
        Opportunity addrowopp;
        
        //Start test from here
        test.StartTest();
        
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        PageReference testpr = cox.addRow();
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                addrowopp = xopp.opp;
                xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        testpr = cox.saveAll();
        
        //Stop test here
        test.StopTest();
    }
    
    // test booking contracts with Doc MTMs
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testCoreContractOppExt_DocMTMs() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            CloseDate = system.today(),
            Sales_Pursuit_Products__c  = 'APS',
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
        );
        insert testcon;
        
        Opportunity addrowopp;
        
        //Start test from here
        test.StartTest();
        
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        PageReference testpr = cox.addRow();
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                addrowopp = xopp.opp;
                xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        testpr = cox.saveAll();
        
        //Stop test here
        test.StopTest();
    }
    
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testTDContractOppExt() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='PT Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid: null,
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            Sales_Pursuit_Products__c  = 'APS',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 5,
            Main_Contact__c = testcontact.id
        );
        insert testcon;
        
        Opportunity addrowopp;
        
        //Start test from here
        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        PageReference testpr = cox.addRow();
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) xopp.setSelected(true);
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp.opp.CloseDate == null) {
                addrowopp = xopp.opp;
                xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        testpr = cox.saveAll();
        
        //Stop test here
        test.StopTest();
    }
    
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testBIContractOppExt() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='PT Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null, // NB - 3/24/2011 - Modified to allow for deployment.  Utilizes new code (above) outlined in Try Catch block.  
            AccountID = acc.id,
            Name = 'testopp',
            StageName = 'Closed Won',
            Sales_Pursuit_Products__c  = 'APS',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            //Program__c = [select id from Program__c limit 1].id, // NB - 3/24/2011 - Removed to allow for deployment and make code data independant.  Added above line
            Years_In_Term__c = 5
        );
        insert testcon;
        
        Opportunity addrowopp;
        String dstr;
        list<Integer> dates;
        
        //Start test from here
        test.StartTest();
        
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        PageReference testpr = cox.addRow();
        
        for (ContractOpp_Ext.xopp xopp : cox.displaylist) {
            if (xopp == cox.displaylist[1]) {
                xopp.setSelected(true);
            }
            if (xopp == cox.displaylist[2]) xopp.opp.Decision_Type__c = 'Fixed Term';
            if (xopp == cox.displaylist[3]) {
                //get and set for xopp class
                //start date methods
                xopp.setStartDate('not a good date');
                
                xopp.setStartDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getStartDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                
                //end date methods
                xopp.setEndDate('not a good date');
                
                xopp.setEndDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getEndDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                
                //opt out date methods
                xopp.setOptOutDate('not a good date');
                
                xopp.setOptOutDate(system.today().month() + '/' + system.today().day() + '/' + system.today().year());
                dstr = xopp.getOptOutDate();
                dates = new list<Integer>();
                for (String s : dstr.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
            }
            if (xopp.opp.CloseDate == null) {
                addrowopp = xopp.opp;
                xopp.opp.Start__c = system.today().addDays(10);
            }
            xopp.opp.StageName = 'Pending';
            xopp.opp.OwnerID = testsourceopp.OwnerID;
        }
        
        //Should be one to delete
        testpr = cox.deleteSelected();
        
        testpr = cox.saveAll();
        
        test.StopTest();
    }
    
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testshortcorerenewalandCancel() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*
        renewal sourceopp
        1 year RI contract
        pool year on opp
        cancelall
        */
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // get the TD AM Standard Opp record type
        Id rtid = [select id from Recordtype where Name='PT Marketing' and SObjectType='Opportunity' limit 1].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        Contact testcontact = TestUtilities.CreateNewContact(acc, true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null,// NB - 3/24/2011 - Modified to allow for deployment.
            AccountID = acc.id,
            Name = 'testopp',
            Pool_Year__c = '2011',
            StageName = 'Closed Won',
            Sales_Pursuit_Products__c  = 'APS',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        //Start testing from here
        test.StartTest();
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            //Program__c = [select id from Program__c limit 1].id, // NB - 3/24/2011 - Removed to allow for deployment and added line above to handle this.
            Years_In_Term__c = 1
        );
        
        insert testcon;
        
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        PageReference testpr = cox.cancelAll();
        
        test.StopTest();
        
    }
    
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testmethod void testshortcorenbb() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        /*
        renewal sourceopp
        1 year RI contract
        pool year on opp
        cancelall
        */
        
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        Id rtid = [select id from Recordtype where Name='RI Marketing' and SObjectType='Opportunity' limit 1].Id;
        //Comment out by Rajeev Jain - 09/04/2020 - CR-20200217-13756 (As per CR Delete the RecordType )
        //Id newrtid= [select id from Recordtype where Name = 'RI AM First Year Opp' and SObjectType = 'Opportunity'].Id;
        
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testsourceopp = new Opportunity(
            RecordtypeID = rtid != null ? rtid : null,
            AccountId = acc.id,
            Name = 'testopp',
            Pool_Year__c = '2011',
            StageName = 'Closed Won',
            Sales_Pursuit_Products__c  = 'APS',
            CloseDate = system.today(),
            OwnerID = [select id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1].id
        );
        insert testsourceopp;
        
        Program__c testProgram = TestUtilities.CreateNewProgram(null, 'TES', 'No', null, true);
        
        Contract__c testcon = new Contract__c(
            Payer_Account__c = testsourceopp.AccountID,
            Source_Opportunity__c = testsourceopp.id,
            Start__c = system.today(),
            End__c = system.today().addYears(5),
            Program__c = testProgram.id,
            Years_In_Term__c = 1
        );
        insert testcon;
        
        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        
        //Reinstantiate Another Instance of Contract Controller
        ContractOpp_Ext cox1 = new ContractOpp_Ext(stdcon);
        
        //Reset Source Opportunity Instance dates to cover 100% code cover of the controller
        if(cox1.displaylist.size() > 0){
            cox1.displaylist[0].opp.Start__c = null;
            String str1 = cox1.displaylist[0].getStartDate();
            
            cox1.displaylist[0].opp.End__c = null;
            String str2 = cox1.displaylist[0].getEndDate();
            
            cox1.displaylist[0].opp.Opt_Out_Date__c = null;
            String str3 = cox1.displaylist[0].getOptOutDate();
            
            Boolean isSelected = cox1.displaylist[0].getSelected();
        }
        test.StopTest();
    }
    
    /**
    * 
    * @description: create a contract with no Source Opportunity related to it.
    * verify that a user-friendly error message is presented to the user.
    * 
    **/
    static testmethod void testContractExt_NoOpportunity() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        
        Contract__c testCon = testUtilities.CreateNewContract(true);
        Opportunity addrowopp;
        
        test.StartTest();
        ApexPages.standardController stdcon = new ApexPages.standardController(testcon);
        test.setCurrentPage(Page.ContractOppCreator);
        ApexPages.currentPage().getParameters().put('id',testcon.id);
        ContractOpp_Ext cox = new ContractOpp_Ext(stdcon);
        test.stopTest();
    }
}