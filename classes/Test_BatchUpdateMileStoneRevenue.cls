@isTest
public class Test_BatchUpdateMileStoneRevenue {
	@testSetup 
    static void setup() {
        //Insert deployment records
        List<Deployment__c> depRecsList = new List<Deployment__c>();
        depRecsList.add(new Deployment__c (Name = 'Dep1'));
        depRecsList.add(new Deployment__c(Name = 'Dep2'));
        insert depRecsList;
        
        //Insert pse__Proj__c record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.Name = 'PsaProject1';
        psaProject.pse__Is_Active__c = true;
        insert psaProject;
        
        //Insert MileStone records with new Deployments Ids
        List<pse__Milestone__c> mileStoneList = new List<pse__Milestone__c>();
        mileStoneList.add(new pse__Milestone__c(Name ='MStone1',pse__Target_Date__c = Date.today(),EAB_Deployment__c = depRecsList[0].Id,pse__Project__c = psaProject.id));
        mileStoneList.add(new pse__Milestone__c(Name ='MStone2',pse__Target_Date__c = Date.today(),EAB_Deployment__c = depRecsList[1].Id,pse__Project__c = psaProject.id));
        insert mileStoneList;
        
        //Insert ABC Revenue records with new Deployments Ids
        List<Abc_Revenue__c> abcRevList = new List<Abc_Revenue__c>();
        abcRevList.add(new Abc_Revenue__c(Deployment__c = depRecsList[0].id,Fee_Type__c = 'Setup_Implementation'));
        abcRevList.add(new Abc_Revenue__c(Deployment__c = depRecsList[1].id,Fee_Type__c = 'Setup_Implementation'));
        insert abcRevList;
        
    }
    @isTest
    static void testMethod1(){
        
        test.startTest();
        Batch_UpdateMilestoneRevenue batchObj = new Batch_UpdateMilestoneRevenue();
        Id batchId = Database.executeBatch(batchObj);
        test.stopTest();
        //pse__Milestone__c rec = [select id,name,revenue__c from  pse__Milestone__c where revenue__c != null];
        integer countRev = [select count() from  pse__Milestone__c where revenue__c != null];
        system.assertEquals(2, countRev);
        
    }
}