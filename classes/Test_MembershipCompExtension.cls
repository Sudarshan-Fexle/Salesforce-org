/**
 *   Purpose         :     Test class for MembershipCompExtension
 *
 *   Revision Log    :     V_1.0 - 10/17/2019 - Victor Hanson - Added test methods
**/
@isTest
private class Test_MembershipCompExtension {
    
    @testSetup static void setup() {
        
        //create a Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //set trigger bypass
        util.bypassAllTriggers = true;
        
        //get the program's related product and update the family
        prog = [SELECT Id, Product__c FROM Program__c WHERE Id = :prog.Id];
        Product2 p2 = new Product2(Id = prog.Product__c, Family = 'EAB Tech');
        update p2;
        
        //create an institution
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //create some memberships with varying status values
        List<String> membershipStatusValues = new List<String> { 'Prospect - Pure', 'Prospect - Past Member', 'Member - Payer' };
        List<Membership__c> mems = new List<Membership__c>();
        for (String statusString : membershipStatusValues) {
            Membership__c mem = TestUtilities.CreateNewMembership(acct.Id, prog.Id, false);
            mem.Current_Year_Annual_Fee__c = 1000;
            mem.Current_Year_Travel_Fee__c = 500;
            mem.Membership_Status_Text__c = statusString;
            mems.add(mem);
        }
        insert mems;
        
        //create 
    }
    
    
    /**
     * @description: test the getmemberships method
     **/
    static testmethod void testGetMemberships() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        //get the memberships created in test setup
        List<Membership__c> mems = MembershipCompExtension.getMemberships(new List<Id> { accts[0].Id });
        system.assertNotEquals(0, mems.size());
    }
    
    
    /**
     * @description: test the GetActiveMembershipWrapperList method
     **/
    static testmethod void testGetActiveMembershipWrapperList() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        //get the memberships created in test setup
        List<MembershipCompExtension.membershipFamilyWrapper> memWrappers = MembershipCompExtension.getActiveMembershipWrapperList(new List<Id> { accts[0].Id });
        system.assertNotEquals(0, memWrappers.size());
        system.assertEquals(1500, memWrappers[0].memberships[0].membership.Sum_Of_Current_Period_Fees__c);
    }
    
    /**
     * @description: test the getChildAccounts method
     * Created by - Abhinav Sharma - 10/23/2020 - CR-20201008-14592
     **/
    static testmethod void testGetChildAccounts() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        //create an institution
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_Relationship_Status_Text__c = Constants.MEMBER;
        acct.ParentId = accts[0].Id;
        
        Insert acct;
        
        accts.add(acct);
        
        //get the memberships created in test setup
        List<Account> accounts = MembershipCompExtension.getChildAccounts(new List<Id> { accts[1].Id });
        system.assertNotEquals(1, accounts.size());
    }
    
}