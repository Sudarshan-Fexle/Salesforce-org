/**
 * 	Description 	:	test class for AdvancedLookupCtrl Class 
 * 
 * 	Revision Logs	:	V1.0 - 07/09/2021 - Chirag Soni - Created w.r.t CR-20211005-15489
 * 			
 **/

@isTest
Private class Test_AdvancedLookupCtrl {
    
    static testmethod void testGetObjectTypeForPrefix(){
        
        //get prefix of Opportunity Object for adding in pageref parameter. 
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        Test.startTest();
        
        //set the parameter in page reference for advancedLookup VF page  
        Test.setCurrentPage(Page.advancedLookup);
        
        // lktp parameter & lksrch parameter
        ApexPages.currentPage().getParameters().put('lktp',keyPrefix);
        ApexPages.currentPage().getParameters().put('lksrch','Active_Renewal__c=false');
        
        //create instance of controller so that constructor will call
        AdvancedLookupCtrl advLookupCtrl = new AdvancedLookupCtrl();
        
        //assert to check Object type
        System.assertEquals('Opportunity', advLookupCtrl.objectType);
        
        //assert to check searchFilter
        System.assertEquals('Active_Renewal__c=false', advLookupCtrl.searchFilter);
        
        Test.stopTest();
    }
}