/**
 *  Purpose         :   Test class for OpportunityCompController
 *  
 *  note			: 	seeAllData=true because testOppSummary executes a report, which requires seealldata=true
 *
 *  Revision Log    :   V_1.0 - 10/17/2019 - Victor Hanson - Added test methods
 *		    		:   V_1.1 - 10/12/2021 - Chirag Soni - CR-20210910-15426 - Modified the Method testGetOpenOpps(), testOppSummary()
**/
    
@isTest(SeeAllData=true)
private class Test_OpportunityCompController {
    
    /**
     * @description: test the getOpportunitySummaries method
     * @Version	   : V1.0 - Modified by - Chirag Soni - CR-20210910-15426 - 10/12/2021 - Updated the Program Acronym name to keep unique program Acronym
     **/
    static testmethod void testOppSummary() {
        //create a Program and corresponding Product
        //Updated by - Chirag Soni - CR-20210910-15426 - 10/12/2021 - Updated the Program Acronym name
        Program__c p = TestUtilities.CreateNewProgram(null, 'TEST', 'Yes', 'NBB', true);
        
        //get program and verify product is created
        p = [SELECT Id, Product__c FROM Program__c WHERE Id = :p.Id];
        system.assertNotEquals(null, p.Product__c, 'Product should be populated.');
        
        Util.bypassAllTriggers = true;
        
        //create the opportunity
        Opportunity o = TestUtilities.CreateNewOpportunity(true);
        
        //get the opportunity and accountId
        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        system.assertEquals(1, opps.size());
        
        List<OpportunityCompController.oppSummary> oppSummaries = OpportunityCompController.getOpportunitySummaries(new List<Id> { opps[0].AccountId });
        system.assertNotEquals(null, oppSummaries);
    }
    
    /**
     * @description: test the getOpenOpps method
     * @Version	   : V1.0 - Modified by - Chirag Soni - CR-20210910-15426 - 10/12/2021 - Updated the Program Acronym name to keep unique program Acronym
     **/
    static testmethod void testGetOpenOpps() {
        //create a Program and corresponding Product
        //Updated by - Chirag Soni - CR-20210910-15426 - 10/12/2021 - Updated the Program Acronym name
        Program__c p = TestUtilities.CreateNewProgram(null, 'TEST', 'Yes', 'NBB', true);
        
        //get program and verify product is created
        p = [SELECT Id, Product__c FROM Program__c WHERE Id = :p.Id];
        system.assertNotEquals(null, p.Product__c, 'Product should be populated.');
        
        Util.bypassAllTriggers = true;
        
        //create account
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        //create the opportunity
        Opportunity o = TestUtilities.CreateNewOpportunity(accountId, false);
        o.Program__c = p.Id;
        insert o;
        
        //get the opportunity and accountId
        List<Opportunity> opps = [SELECT Id, CloseDate, IsClosed, AccountId FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        system.assertEquals(1, opps.size());
        
        List<Id> accountIds = new List<Id> { opps[0].AccountId };
            system.assertEquals(1, accountIds.size());
        
        List<OpportunityCompController.opportunityWrapper> oppWrappers = OpportunityCompController.getOpenOpps(accountIds);
        system.assertEquals(1, oppWrappers.size());
    }
}