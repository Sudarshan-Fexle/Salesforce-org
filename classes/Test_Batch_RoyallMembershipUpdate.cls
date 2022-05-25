/**
 *  Description     :   This Apex Test class used to test the "Batch_RoyallMembershipUpdate" functionality.
 * 
 *  Created By      :   Abhishek Mishra
 * 
 *  Created Date    :   08/16/2021
 * 
 *  Revision Logs   :   V1.0 - Abhishek Mishra - CR-20211005-15489 - 08/16/2021 - increase code coverage
 *
 **/
@isTest(seeAllData = false)
private class Test_Batch_RoyallMembershipUpdate {
    
    private static final string Royall_Institution_Formal_Name = 'Test Royall Institution';
    
   /**
    * @description: setup test data for all tests
    **/
    @testSetup
    static void setup() {
        
        //create custom setting default so the trigger will fire to auto-populate programPackage fields
        Account_Status_Management__c acctStatusMgmt = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert acctStatusMgmt;
        
        //create the Royall programs
        list<Program__c> royallPrograms = new list<Program__c>();
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Advancement',
                                          Program_Acronym__c='RYAF'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Admissions - Graduate',
                                          Program_Acronym__c='RYAG'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Admissions - Undergraduate',
                                          Program_Acronym__c='RYAU'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='RYFA - Royall Admissions - Financial Aid',
                                          Program_Acronym__c='RYFA'));
        util.BypassAllTriggers = true;
        insert royallPrograms;
        util.BypassAllTriggers = false;
        
        //setup a US Education Institution
        Account acct = TestUtilities.CreateNewAccount('US Education', false);
        acct.Account_Formal_Name__c = 'Test Institution';
        insert acct;
        
        //setup a Royall Institutions
        list<Account> royallAccts = new list<Account>();
        
        //Graduate
        Account acctRoyallGrad = TestUtilities.CreateNewAccount(false);
        acctRoyallGrad.RecordTypeId = Constants.Account_Royall_Graduate_RT_ID;
        acctRoyallGrad.Account_Formal_Name__c = Royall_Institution_Formal_Name + '_Graduate';
        acctRoyallGrad.ParentId = acct.Id;
        royallAccts.add(acctRoyallGrad);
        insert royallAccts;
        
    }
    
    //Method to test Batch_RoyallMembershipUpdate
    static testmethod void testBatch_RoyallMembershipUpdate() {
        Integer currentFY = shift_get_fiscal_year.current(); 
        
        Account acct,acctRoyallAdvancement,acctRoyallUndergrad,acctRoyallGrad;
        
        //get the institution and related memberships
        list<Account> accts = [SELECT Id, RecordType.Name, Account_Formal_Name__c, (SELECT Id, Membership_Status_Text__c/*, Active_Program_Package__c*/ FROM Memberships__r) FROM Account];
        for (Account a : accts) {
            if (a.Account_Formal_Name__c == 'Test Institution')
                acct = a;
            else if (a.RecordTypeId == Constants.Account_Royall_Graduate_RT_ID)
                acctRoyallGrad = a;
        }
        
        system.assertEquals('US Education', acct.RecordType.Name);
        system.assertEquals(4, acct.Memberships__r.size());
        
        //List of program Package            
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        //Test data of  Program Package (create an active program package for the current calendar year)
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_CurrentYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_NextYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        //bypass triggers when inserting, so it doesn't trigger an update immediately
        util.BypassAllTriggers = true;
        insert progPacks;
        util.BypassAllTriggers = false;
        
        //start here 
        acct = [SELECT Id, 
                (SELECT Id, Name, Membership_Status_Text__c, Program_Acronym__c FROM Memberships__r)
                FROM Account WHERE Id = :acct.Id];
        
        //execute the test
        test.startTest();
        Batch_RoyallMembershipUpdate b = new Batch_RoyallMembershipUpdate();
        b.QueryString = 'SELECT Id FROM Program_Package__c WHERE CreatedDate = TODAY';
        database.executeBatch(b, 50);
        
        //use Case 2nd when queryString == null
        Batch_RoyallMembershipUpdate b1 = new Batch_RoyallMembershipUpdate();
        database.executeBatch(b1, 50);
        
        test.stopTest();
        
        //get the institution and updated memberships
        acct = [SELECT Id, 
                (SELECT Id, Name, Membership_Status_Text__c, Program_Acronym__c FROM Memberships__r)
                FROM Account WHERE Id = :acct.Id];
        //end here
    }
}