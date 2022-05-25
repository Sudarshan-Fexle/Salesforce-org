/**
*   Purpose         :   Test class for Batch_SiteContentRecommendations
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
private class Test_Batch_SiteContentRecommendations 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        List<Account>  accts = new List<Account>();
        accts.add(new Account(Name = 'Test1', Status__c = 'Active',Research_Strategic_Leader__c = UserInfo.getUserId()));
        accts.add(new Account(Name = 'Test2', Status__c = 'Active', Research_Strategic_Leader__c = UserInfo.getUserId()));
        insert accts;
        
        Contact cont = TestUtilities.CreateNewcontact(true);
        
        List<Team_Role__c> assignmentRoles =  new List<Team_Role__c>();
        assignmentRoles.add(new Team_Role__c(Name = 'Test Role', Business_Owner__c = cont.Id, Entity__c = 'EAB', Institution__c = true, 
                                             Active__c = true, Institution_Role_External__c = true)); 
        insert assignmentRoles;
        System.assertEquals(1, assignmentRoles.size());
        
        List<Institution_Roles__c> institutionRoles = new List<Institution_Roles__c>();
        institutionRoles.add(new Institution_Roles__c(Name = 'Institution Role',Assignment_Role__c = assignmentRoles[0].Id, Institution__c = accts[0].Id));
		insert institutionRoles;
        System.assertEquals(1, institutionRoles.size());
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_createSCRs()
    {
        List<Institution_Roles__c> institutionRoles = [SELECT Id FROM Institution_Roles__c]; 
        List<Team_Role__c> assignmentRoles = [SELECT Id FROM Team_Role__c];
        List<Account> strtegicLeaderAccount = [Select Id,Research_Strategic_Leader__c From Account];
        
        Set<Id> accIds = new Set<Id>();
        accIds.add(strtegicLeaderAccount[0].Id);
        accIds.add(strtegicLeaderAccount[1].Id);
        
        
        Test.startTest();
        Batch_SiteContentRecommendations b = new Batch_SiteContentRecommendations(accIds, null,'strategicLeader');
        database.executeBatch(b);
        
        Test.stopTest();
        
    }

}