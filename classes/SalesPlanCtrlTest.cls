@isTest
public class SalesPlanCtrlTest {
    /*
    @Version    : V1.0 -  Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    */
    @testSetup
    public static void setup(){
        
        // TO DO: implement unit test
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        String testString;

        //To be fixed : Test_GenerateObjectData.createCustomSettings(); 

        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        Account acc = new Account(Name='Acc1, tx');
        insert acc;

        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity opp = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,Sales_Pursuit_Products__c  = 'APS',stagename='1 - Plan', closedate=Date.today(), AccountId=acc.Id);
        system.debug('@opp'+opp);
        insert opp;

        Opportunity_Stage__c opStage = new Opportunity_Stage__c();
        opStage.Name = 'Disqualified';
        INSERT opStage;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='1 - Plan');
        testStageObject.Opportunity_Record_Type__c = 'Products and Services';
        testStageObject.Opportunity_Stage__c = opStage.Id;
        insert testStageObject;
        
        Objective_Action__c testObjectiveAction = new Objective_Action__c();
        testObjectiveAction.Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.Opportunity_Record_Type__c = 'Products and Services';
        testObjectiveAction.Name = 'Discover?';
        insert testObjectiveAction;
        
        Task tk = new Task(subject='test', ActivityDate=Date.today(), OwnerId=UserInfo.getUserId(), priority='Normal', status='Not Started');
        tk.whatId = opp.Id;
        tk.StageObjectiveID__c = testStageObject.Id;
        tk.ObjectiveActionID__c = testObjectiveAction.Id;
        INSERT tk;

        SP_Exempt_Products__c testExmp = new SP_Exempt_Products__c();
        testExmp.Name = 'test1';
        insert testExmp;

         SP_Exempt_Products__c testExmp2 = new SP_Exempt_Products__c();
        testExmp2.Name = 'test2';
        insert testExmp2;
        

        
    }
    
    @isTest
    public static void unitTest(){
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
        Opportunity_Stage__c opStage = new Opportunity_Stage__c();
        opStage.Name = 'Disqualified';
        INSERT opStage;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='1 - Plan');
        testStageObject.Opportunity_Record_Type__c = 'Products and Services';
        testStageObject.Opportunity_Stage__c = opStage.Id;
        insert testStageObject;
        
        List<Stage_Objective__c> stageObjectives = new List<Stage_Objective__c>();
        stageObjectives.add(testStageObject);
        
        
        System.runAs(user2) {
            Opportunity opp = [SELECT Id,StageName,Name FROM Opportunity LIMIT 1];
            SalesPlanCtrl.initializeData(opp.Id);    
            SalesPlanCtrl.saveActi(new List<Task>{new Task(subject='test', ActivityDate=Date.today(), OwnerId=user2.Id, priority='Normal', status='Not Started')},
                                  opp, '');
            SalesPlanCtrl.createCoachingTask(opp.Id, opp.StageName, null);
            SalesPlanCtrl.requestCoaching(testStageObject.Id, null, user2, opp, 'test@vepcg.com', String.valueOf(user.Id));
            SalesPlanCtrl.sendManagerCoachingEmail(testStageObject.Id, null, user2, opp, 'test@vepcg.com', String.valueOf(user.Id), 'url');
            SalesPlanCtrl.getManagerIdByEmail('SPTEST2@noemail.com');
            SalesPlanCtrl.SelectOptionWithDescription spd = new SalesPlanCtrl.SelectOptionWithDescription('value','label','description');
            SalesPlanCtrl.getOpportunityRecordById(opp.Id);
         
        }
    }
}