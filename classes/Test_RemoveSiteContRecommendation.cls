/*
 * Purpose 	:	Test class for the code coverage of RemoveSiteContRecommendationController
 * 
 * CreatedDate	: 	13/10/2019
 * 
 * RevisionLog	:	V_1.0 -Created - Dipesh Gupta -CR-20190823-13280
 * 			V_1.1 - Updated - Subhash - CR-20211012-15511
 * */

@IsTest
public class Test_RemoveSiteContRecommendation 
{
	
    @TestSetup static void testdata()
    {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        List<Account> acc = new List<Account>();
        acc.add(new Account(RecordTypeId = RecordTypeIdAccount , Name = 'Test', Status__c = 'Active'));
        insert acc;
        
        List<Site_Content_Recommendation__c> siteContRecommendations = new List<Site_Content_Recommendation__c>();
        siteContRecommendations.add(new Site_Content_Recommendation__c(Institution__c = acc[0].Id));
        siteContRecommendations.add(new Site_Content_Recommendation__c(Institution__c = acc[0].Id));
        siteContRecommendations.add(new Site_Content_Recommendation__c(Institution__c = acc[0].Id));
        
        insert siteContRecommendations;
    }
    
    @IsTest static void testRemoveSiteContRecommendationController()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.StartTest(); 
        Site_Content_Recommendation__c scr = [SELECT Id, Institution__c FROM Site_Content_Recommendation__c WHERE Institution__c =: acc.Id LIMIT 1];
        PageReference pageRef = Page.RemoveSiteContentRecommendations;
        pageRef.getParameters().put('institutionId', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        RemoveSiteContRecommendationController rscc = new RemoveSiteContRecommendationController();
        
        List<RemoveSiteContRecommendationController.WrapperOfSiteContRecommendation> wrapper = new List<RemoveSiteContRecommendationController.WrapperOfSiteContRecommendation>();
        RemoveSiteContRecommendationController.WrapperOfSiteContRecommendation rsccWrap = new RemoveSiteContRecommendationController.WrapperOfSiteContRecommendation(scr, true);
        rsccWrap.siteContRecommendation = scr;
        rsccWrap.check = true;
        wrapper.add(rsccWrap);
        rscc.deleteSelectedSiteContRecommendation();
        
        //Added by Subhash - CR-20211012-15511
        rscc.redirectToInstitution();
        rscc.spin();
        
        Test.StopTest();
    }
}