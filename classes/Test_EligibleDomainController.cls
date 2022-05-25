/**
*   Purpose         :   Test class for EligibleDomainController
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   07/14/2020
*
*   Revision Log    :   V_1.0 - Created - Mahendra Swarnakar
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_EligibleDomainController 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        String US_CORPORATE_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Corporate').getRecordTypeId();
        String US_EDUCATION_RTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId();
        
        List<Account>  accts = new List<Account>();
        accts.add(new Account(Name = 'Test1', Status__c = 'Active',Research_Strategic_Leader__c = UserInfo.getUserId(),recordTypeId = US_CORPORATE_RTYPE));
        accts.add(new Account(Name = 'Test2', Status__c = 'Active', Research_Strategic_Leader__c = UserInfo.getUserId(),recordTypeId = US_EDUCATION_RTYPE));
        insert accts;
        
        List<Eligible_Domain__c> eligibleDomain = new list<Eligible_Domain__c>();
        eligibleDomain.add(new Eligible_Domain__c(Qualified_Domain__c ='org.com',Is_Included__c = false, account__c = accts[0].Id));
        eligibleDomain.add(new Eligible_Domain__c(Qualified_Domain__c ='eab.com',Is_Included__c = true, account__c = accts[1].Id));
        insert eligibleDomain;
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_checkEligibleDomain()
    {
        List<Eligible_Domain__c> domain = [Select Qualified_Domain__c,Is_Included__c,account__c FROM Eligible_Domain__c ];
        List<Account> strtegicLeaderAccount = [Select Id,Research_Strategic_Leader__c,Status__c From Account];
       
        Test.startTest();
        String msg = EligibleDomainController.checkEligibleDomain(strtegicLeaderAccount[0].Id);
        system.assertEquals('This institution does not have an associated eligible domain record, which impacts eab.com access.', msg);
        Test.stopTest();
        
    }
    
}