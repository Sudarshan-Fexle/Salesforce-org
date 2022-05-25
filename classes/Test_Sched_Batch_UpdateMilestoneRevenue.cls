/**
 * Description	:	Test classs for the Schedule_Batch_UpdateMilestoneRevenue
 * 
 * Created By 	:	Abhishek Mishra
 * 
 * Created Date	: 	07/12/2021 
 * 
 * Revision Log	:	V_1.0 - Created - Abhishek Mishra - CR-20211005-15489
 * 
 * Code Coverage:	100%	 	
 **/

@isTest(seeAllData=false)
public class Test_Sched_Batch_UpdateMilestoneRevenue 
{
    @testSetup static void testSetupData() 
    {
        Util.BypassAllTriggers = true;
        
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
        
        Util.BypassAllTriggers = false;
    }
    
    @isTest static void test_Schedule_Batch_UpdateMilestoneRevenue()
    {
        Test.startTest();
        
        //Schedule batch after 5 min.
        Datetime sysTime = DateTime.now();
        Integer addTime = Integer.ValueOf(5);
        sysTime = sysTime.addMinutes(addTime);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Schedule the job
        Schedule_Batch_UpdateMilestoneRevenue schedJob = new Schedule_Batch_UpdateMilestoneRevenue();
        System.Schedule('Schedular job test',chron_exp,schedJob);
        
        Test.stopTest();
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        List<AsyncApexJob> batchApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        
        //Asserts
        System.assertEquals('Schedule_Batch_UpdateMilestoneRevenue', asyncApexJob[0].ApexClass.Name);
        System.assertEquals('Batch_UpdateMilestoneRevenue', batchApexJob[0].ApexClass.Name);
    }
}