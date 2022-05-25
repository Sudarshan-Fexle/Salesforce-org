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
private class Test_Batch_Account_OutreachProgs_v2 {
    
    /**
     * Revision log :   V1.1 - Modify by - Victor Hanson - 05/31/2019 - CR-20190531-13159 - updated test method to use the default query so we'll be aware of query failures in the future
     *                  V1.2 - Modified By - Abhinav Sharma - 8/13/2020 - CR-20180808-12492 - comment the Academies_Memberships__c Fields related changes
     * 			V1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
     **/
    static testmethod void testBatch_Account_OutreachProgs_v2 ()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        Util.ByPassAlltriggers = true;
        
        Contact testContact = TestUtilities.CreateNewContact(true);
        
        // Create test programs
        List<Program__c> testProgs = new List<Program__c>();
        
        Program__c pAcad = new Program__c(
            Program_Acronym__c = 'TAC',
            Integration_Support__c = Constants.ZENDESK,
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'TD');
        testProgs.add(pAcad);
        
        Program__c pBI = new Program__c(
            Program_Acronym__c = 'TBI',
            Integration_Support__c = Constants.ZENDESK,
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'PT');
        testProgs.add(pBI);
            
        Program__c pCore = new Program__c(
            Program_Acronym__c = 'TCO',
            Integration_Support__c = Constants.ZENDESK,
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'RI');
        testProgs.add(pCore);
        
        Program__c pHWorks = new Program__c(
            Program_Acronym__c = 'THW',
            Integration_Support__c = Constants.ZENDESK,
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'CM');
        testProgs.add(pHWorks);
        
        insert testProgs;
        
        // Create test accounts
        List<Account> testAccts = new List<Account>();
        
        for(integer i = 0; i < 10; i++)
        {
            if(i < 8)
                testAccts.add(new Account(Name='TestAcct' + i.format()));
            else
                testAccts.add(new Account(Name='TestAcct' + i.format(), Today__c = system.today().addDays(-1)));
        }
        
        insert testAccts;
        
        // Create Contracts
        Contract__c testContract1 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        Contract__c testContract2 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        
        insert testContract1;
        insert testContract2;
        
        // Create test memberships
        List<Membership__c> testMembs = new List<Membership__c>();
        
        for(Account acc : testAccts)
        {
            // Membership Status = 'Member-Honorary'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pHWorks.Id));
                //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035
            // Membership Status does not contain 'Member' && Prospect Status = 'Available For Outreach'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pHWorks.Id));
        }
        util.BypassAllTriggers = false;
        insert testMembs;
        
        // Start testing
        Batch_Account_OutreachProgs_v2 batch = new Batch_Account_OutreachProgs_v2();
        test.startTest();
        Util.BypassAllTriggers = false;
        id batchId = database.executeBatch(batch);
        test.stopTest();
        
        //VH 5/31/2019: get batch details
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :batchId];
        system.assertEquals(1, jobs.size());
        system.assertEquals('Completed', jobs[0].Status);
        
        system.assertNotEquals(null, batchId);
        
        
        //11/07/2012 - Bhavi - CR-20121016-1624
         //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Academies_Memberships__c
        Account checkAccount = [select Id, Name, Core_Memberships__c, BI_Memberships__c, /*Academies_Memberships__c,*/ Zendesk_Support__c,
            Core_Programs_Available_for_Outreach__c, Active_RI_Memberships__c, Active_PT_Memberships__c, Paid_PT_Memberships__c, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c
            from Account where Id = :testAccts[5].Id];
        
        //system.assertNotEquals(null, checkAccount.Core_Memberships__c);
        system.assertNotEquals(false, checkAccount.Zendesk_Support__c);
        system.assertNotEquals(null, checkAccount.BI_Memberships__c);
        
        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Academies_Memberships__c
        //system.assertNotEquals(null, checkAccount.Academies_Memberships__c);
        
        /*VRH temporarily disabled until Bhavi sorts out the Prospect Status formula on Memberships*/
        //Commented the assert as fields are marked as zzz
        /*system.assertNotEquals(null, checkAccount.Core_Programs_Available_for_Outreach__c);
        system.assertNotEquals(null, checkAccount.Academy_Programs_Available_for_Outreach__c);
        system.assertNotEquals(null, checkAccount.BI_Programs_Available_for_Outreach__c);
        system.assertEquals(true, checkAccount.Active_RI_Memberships__c.toLowerCase().contains('tco'));
        system.assertEquals(true, checkAccount.Active_PT_Memberships__c.toLowerCase().contains('tbi'));*/
     }
    
    static testmethod void testRecordLockUseCase()
    {
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        Util.ByPassAlltriggers = true;
        
        Account acc = new Account(Name = 'testacc1010', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = acc.Id,Main_Contact__c = cont.Id, Name = 'Test', StageName = 'Pending', CloseDate = System.today(), Are_They_Evaluating__c = 'Yes', 
                                        Is_there_are_hard_next_step__c = 'Yes', Initial_Visit_Date__c = date.today());
        insert opp;
        Event evt = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(4), EndDateTime = datetime.now().addDays(5));
        insert evt;     

        Event evt2 = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(5), EndDateTime = datetime.now().addDays(6));
        insert evt2;
            
        Batch_Opportunity_VisitSummaries batchProcess1 = new Batch_Opportunity_VisitSummaries();
        Batch_Opportunity_VisitSummaries batchProcess2 = new Batch_Opportunity_VisitSummaries();
        
        //Start Test from here
        Test.startTest();
        
        id batchId1 = database.executeBatch(batchProcess1,1);
        id batchId2 = database.executeBatch(batchProcess2,1);
       
               
        //STop test here
        Test.stopTest();
    }
    
    /**
     * Revision log :   v1.1 - Modified By - Victor Hanson - 05/31/2019 - CR-20190531-13159 - updated test method to use the default query so we'll be aware of query failures in the future
     * 		    :   v1.2 - Modified By - Chirag Soni - 11/18/2021 -CR-20210908-15415 - Updated static user id in User_InActive_Ownership_To_SFAdmin__c data creation.
     **/
    @istest static void myUnitTest () {
        
          //Bypass Dupeblocker
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        Util.ByPassAlltriggers = true;
        
        Contact testContact = TestUtilities.CreateNewContact(true);
        
        // Create test programs
        List<Program__c> testProgs = new List<Program__c>();
        
        Program__c pAcad = new Program__c(
            Program_Acronym__c = 'TAC',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'TD');
        testProgs.add(pAcad);
        
        Program__c pBI = new Program__c(
            Program_Acronym__c = 'TBI',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'PT');
        testProgs.add(pBI);
            
        Program__c pCore = new Program__c(
            Program_Acronym__c = 'TCO',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'RI');
        testProgs.add(pCore);
        
        Program__c pHWorks = new Program__c(
            Program_Acronym__c = 'THW',
            Program_Formal_Name__c = 'Test Program Formal',
            Name = 'Test Program',
            Create_Memberships__c = 'No',
            Renewal_Unit_Count__c = 1,
            Business_Line__c = 'CM');
        testProgs.add(pHWorks);
        
        insert testProgs;
        
        // Create test accounts
        List<Account> testAccts = new List<Account>();
        
        for(integer i = 0; i < 10; i++)
        {
            if(i < 8)
                testAccts.add(new Account(Name='TestAcct' + i.format()));
            else
                testAccts.add(new Account(Name='TestAcct' + i.format(), Today__c = system.today().addDays(-1)));
        }
        
        insert testAccts;
        
        // Create Contracts
        Contract__c testContract1 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        Contract__c testContract2 = new Contract__c(
            Name='TestContract', Status__c = 'Honorary', Start__c = system.today().addDays(1), End__c = system.today().addDays(2),
            Negotiated_Amount__c = 1,
            Type__c = 'NBB',
            Year__c = '2010',
            Join_Date__c = system.today().addDays(-5),
            Payer_Account__c = testAccts[0].Id,
            Main_Contact__c = testContact.Id,
            Invoice_Contact__c = testContact.Id,
            Program__c = testProgs[0].Id);
        
        insert testContract1;
        insert testContract2;
        
        // Create test memberships
        List<Membership__c> testMembs = new List<Membership__c>();
        
        for(Account acc : testAccts)
        {
            // Membership Status = 'Member-Honorary'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract1.Id,
                Active_Contract_Idenfied__c = testContract2.Id,
                Program__c = pHWorks.Id));
                
            // Membership Status does not contain 'Member' && Prospect Status = 'Available For Outreach'
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pAcad.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pBI.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pCore.Id));
            
            testMembs.add(new Membership__c(
                Name = 'Test Membership',
                Account_Name__c = acc.Id,
                Earliest_Contract__c = testContract2.Id,
                Active_Contract_Idenfied__c = testContract1.Id,
                Opportunity_in_Outreach__c = 'No',
                Opportunity_in_Prospect__c = 'No',
                /*Most_Recent_NBB_Visit__c = null,*/
                Program__c = pHWorks.Id));
        }
        util.BypassAllTriggers = false;
        insert testMembs;
        
         // Added by -  Chirag Soni - 11/18/2021 -CR-20210908-15415 
         List<User> sfAdminUser = [Select Id, Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
        //create custom setting record 
        //Custom Setting Data 
        User_InActive_Ownership_To_SFAdmin__c inactiveOwnershipData = new User_InActive_Ownership_To_SFAdmin__c();
        inactiveOwnershipData.Batch_Size__c = 20;
        inactiveOwnershipData.Last_N_Hours__c = 24;
        inactiveOwnershipData.SFAdmin_Id__c = sfAdminUser[0].Id; //  Chirag Soni - 11/18/2021 -CR-20210908-15415 - updated 
        insert inactiveOwnershipData;
        
        // Start testing
        Batch_Account_OutreachProgs_v2 batch = new Batch_Account_OutreachProgs_v2();
         
        
        test.startTest();
        Util.BypassAllTriggers = false;
        Id batchId;
        try {
             //Batch class call
             //batch.ExecuteNextJob = true;
             batchId = Database.executeBatch(batch);
                     
        }catch(Exception e) {
            
        }
           
        Test.stopTest();
        
        //VH 12/03/2019: get batch details
        List<AsyncApexJob> jobs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchId];
        system.assertEquals(1, jobs.size());
        system.assertEquals('Completed', jobs[0].Status);
        //VH added 12/03/2019 to verify the job completed without errors
        system.assert(String.isBlank(jobs[0].ExtendedStatus)); 
        
       
    }
    
    
}