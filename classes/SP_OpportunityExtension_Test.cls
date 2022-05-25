@istest
public class SP_OpportunityExtension_Test{
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    public static testMethod void testOpportunityAdvanceStageController(){
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='asd',lastname='dsf',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz',
                                  Is_Ignore_Phrase_Characters__c = true);
        insert con;
        
        
        Opportunity_Stage__c oppStage1 = new Opportunity_Stage__c();
        oppStage1.Name = '1 - Plan';
        insert oppStage1;
        
        Opportunity_Stage__c oppStage2 = new Opportunity_Stage__c();
        oppStage2.Name = '2 - Develop';
        oppStage2.Next_Stage__c = oppStage1.id;
        insert oppStage2;
        
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();

        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity testOpportunity = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,Sales_Pursuit_Products__c  = 'APS',stagename='1 - Plan', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        testOpportunity.Opportunity_Stage__c = oppStage1.Id;
        insert testOpportunity;
        
        SP_OpportunityExtension testOpportunityExtension = new SP_OpportunityExtension(new ApexPages.StandardController(testOpportunity));
        if(testOpportunityExtension.OppStage == null){}
        if(testOpportunityExtension.nextStage == null){}
        if(testOpportunityExtension.advancementCriteria == null){}
        if(testOpportunityExtension.readyToAdvance){}
        testOpportunityExtension.advanceStage();
    }
}