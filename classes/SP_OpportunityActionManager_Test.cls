@isTest
public class SP_OpportunityActionManager_Test{
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    public static testMethod void testOpportunityActionManagerClass()
    {
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='asd',lastname='dsf',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz',
                                  Is_Ignore_Phrase_Characters__c = true
                                 );
        insert con;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
         //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
         //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity opp = new Opportunity(Name='asdasd',Sales_Pursuit_Products__c  = 'APS', RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='Prospecting', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        insert opp;
        
        Stage_Objective__c testStageObject = new Stage_Objective__c(name='Prospecting');
        testStageObject.Opportunity_Record_Type__c = 'Products and Services';
        insert testStageObject;
        
        Objective_Action__c testObjectiveAction = new Objective_Action__c();
        testObjectiveAction.Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.Opportunity_Record_Type__c = 'Products and Services';
        insert testObjectiveAction;
        
        List<Stage_Objective__c> testListStageObjective = new List<Stage_Objective__c>(); 
        testListStageObjective.add(testStageObject);
        List<Task> testListTask = new list<Task>();
        Task testTask = new Task();
        
        //insert testTask;
        
        Map<Id,Objective_Action__c> testMap = new Map<Id,Objective_Action__c>();
        Id testId;
        
        //OpportunityActionManager main class
        SP_OpportunityActionManager testOpportunityActionManager = new SP_OpportunityActionManager(testListStageObjective, testListTask, testMap, opp.Id);
        list<Task> opActs = testOpportunityActionManager.oppActions;
        if(testOpportunityActionManager.stageObjectives == null){}
        testOpportunityActionManager.clear();
        if(testOpportunityActionManager.commitObjectives == null){}
        if(testOpportunityActionManager.advancementCriteria == null){}
        testOpportunityActionManager.resetTasks(testListTask);
        //Objective inner class
        Id conId = [Select Id,contact__c,Name,StageName,RecordTypeId from Opportunity where Id =: opp.Id].contact__c;
        
        SP_OpportunityActionManager.Objective testObjective = new SP_OpportunityActionManager.Objective(testStageObject, opp.Id,conId);
        if(testObjective.actions == null){}
        if(testObjective.isEmpty){}
        testObjective.add(testTask,testObjectiveAction,0);
        //Action inner class
        SP_OpportunityActionManager.Action testAction = new SP_OpportunityActionManager.Action(testObjectiveAction, opp.Id,conId);
        if(testAction.subject == null){}
        if(testAction.committed == null){}
        testAction.linkToView();
        String testVal = '';
        Boolean testBol = testAction.requiredToAdvance;
        testVal = testAction.relatedStage;
        testVal = testAction.oppTypes;
        testVal = testAction.orderTypes;
        testVal = testAction.orderSubTypes;
        testVal = testAction.actionType;
        //testBol = testAction.exemptProds;
        testVal = testAction.bgColor;
        
    }
}