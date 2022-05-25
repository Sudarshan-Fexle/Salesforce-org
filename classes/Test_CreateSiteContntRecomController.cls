/**
*   Purpose         :   Test class for CreateSiteContntRecommendationController
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   06/15/2020
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_CreateSiteContntRecomController 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        List<Account>  accts = new List<Account>();
        accts.add(new Account(Name = 'Test1', Status__c = 'Active' ));
        accts.add(new Account(Name = 'Test2', Status__c = 'Active' ));
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
        String screen1Selection = 'strategicLeader';
        String screenSelection = 'institutionRole';
        String userId = '[{"Id":"'+ UserInfo.getUserId() + '"}]';
        String assignmentRolesId = assignmentRoles[0].Id;
        String institutionRolesId = institutionRoles[0].Id;
        String result = '[{"siteContentId":null,"guid":"118422","title":"COVID-19 Self-Web Audit","url":"","webProgramAccessIds":["1"]},{"siteContentId":null,"guid":"120108","title":"COVID-19\''+'s impact on university fundraising and alumni relations","url":"","webProgramAccessIds":["212"]}]';
        LightningResponseEntity lightningEntity = CreateSiteContntRecommendationController.createSCRs(screen1Selection ,result,
                                                                                                      userId, institutionRolesId);
        
    }

}