@isTest(SeeAllData=true)
public class SP_OpportunityActionPlanExtension_Test {
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    public static testMethod void testOpportunityActionPlanController() {
        String testString;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity opp = new Opportunity(Name='asdasd',Sales_Pursuit_Products__c  = 'APS',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='1 - Plan', closedate=Date.today(), AccountId=acc.Id);
        insert opp;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='1 - Plan');
        testStageObject.Opportunity_Record_Type__c = 'Products and Services';
        insert testStageObject;
        
        Objective_Action__c testObjectiveAction = new Objective_Action__c();
        testObjectiveAction.Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.Opportunity_Record_Type__c = 'Products and Services';
        testObjectiveAction.Name = 'Discover?';
        insert testObjectiveAction;
        
        SP_Exempt_Products__c testExmp = new SP_Exempt_Products__c();
        testExmp.Name = 'test1';
        insert testExmp;
        
         SP_Exempt_Products__c testExmp2 = new SP_Exempt_Products__c();
        testExmp2.Name = 'test2';
        insert testExmp2;
        
        
        Profile p = [Select Id FROM Profile WHERE Name='System Administrator'];
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='SPTEST1@noemail.com');
        insert user;
        User user2 = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='SPTEST2@noemail.com');
        user2.ManagerId = user.Id;
        user2.FirstName = 'test';
        insert user2;
        
        System.runAs(user2) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('/apex/SP_OpportunityActionPlan'));
            System.currentPageReference().getHeaders().put('X-Salesforce-Forwarded-To','test.test');
            SP_OpportunityActionPlanExtension testExtension = new SP_OpportunityActionPlanExtension(new ApexPages.StandardController(opp));
            testString = testExtension.blockTitle;
            testExtension.saveActions();
            testExtension.selectedObjId = testStageObject.Id;
            testExtension.mgrEmail = 'test@nomail.com';
            testExtension.cancelActions();
            
            
            testExtension.FSMapFunc();
            testExtension.closeMgrDialog();
            testExtension.showMgrDialog();
            testExtension.requestCoaching();
            testExtension.requestCoachingNoMgr();
            testExtension.coachingInfo();
            //testExtension.saveActions();
            SP_OpportunityActionPlanExtension.checkExemptProducts('test1;test2');
            testExtension.currentView = 'commit';
            test.stopTest();
        }
        SP_OpportunityActionPlanExtension.createCoachingTask(opp.id,'1 - Plan', UserInfo.getUserId());
    }
}