/**
* Purpose		: Test class for ProjectTaskTriggerHelper
*
* Create By		: Mahendra Swarnakar
*
* Created Date		: 12/09/2020
*
* Revision Log		: V_1.0 - Created - Mahendra Swanakar - CR-20201020-14618
*			: V_1.1 - Modified By - Colin McGloin - CR-20210120-14821 - 01/20/2020
*
* Coverage		: V_1.0 - 97%
*
**/
@isTest(seeAllData = false)
public class Test_ProjectTaskTriggerHelper {
    
    static testMethod void unitTest(){
        
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        insert psaProject;
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;
        
        
        List<pse__Project_Task__c> projTasks = new List<pse__Project_Task__c>();
        projTasks.add(new pse__Project_Task__c(Name = 'Test 1', pse__Parent_Task__c = projectTask.Id, Task_Completion__c = 30));
        projTasks.add(new pse__Project_Task__c(Name = 'Test 2', pse__Parent_Task__c = projectTask.Id, Task_Completion__c = 30));
        projTasks.add(new pse__Project_Task__c(Name = 'Test 3', pse__Parent_Task__c = projectTask.Id, Task_Completion__c = 30));
        
        insert projTasks;
        
        //Start
        Test.StartTest();
        
        for(pse__Project_Task__c projTask : [SELECT Id, Parent_Task_Completion__c FROM pse__Project_Task__c WHERE Id =: projectTask.Id])
        {
            //System.assertEquals(30, projTask.Parent_Task_Completion__c);
        }
        //Stop
        Test.StopTest();
    }
    
    @isTest static void test_validateProjectTasks(){
         
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        insert psaProject;
                
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;
        
        Test.startTest();
        try{
            delete projectTask;
        }
        catch(exception e){
            system.assertEquals('You can not delete ' + projectTask.name,e.getMessage());
        }
        Test.stopTest();
       }
    
    //Modified By - Colin McGloin - CR-20210120-14821 - 01/20/2020
    static testMethod void testSortingLogic(){
        
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        insert psaProject;
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;
        
        
        List<pse__Project_Task__c> projTasks = new List<pse__Project_Task__c>();
        projTasks.add(new pse__Project_Task__c(Name = 'Test 1', pse__Parent_Task__c = projectTask.Id, WBS_External_Source__c = '1.1'));
        projTasks.add(new pse__Project_Task__c(Name = 'Test 2', pse__Parent_Task__c = projectTask.Id, WBS_External_Source__c = '1.2'));
        projTasks.add(new pse__Project_Task__c(Name = 'Test 3', pse__Parent_Task__c = projectTask.Id, WBS_External_Source__c = '1.3'));
        
        insert projTasks;
        
        //Start
        Test.StartTest();
        
        //Initialize Class and pass through Project Id
        ProjectTaskUtility.normalizeTaskStructureForProject(psaProject.Id);
        
        for(pse__Project_Task__c projTask : [SELECT Id, pse__Order__c, pse__Hierarchy_Depth__c FROM pse__Project_Task__c WHERE pse__Parent_Task__c =: projectTask.Id])
        {
            System.assertEquals(1, projTask.pse__Hierarchy_Depth__c);
        }
        //Stop
        Test.StopTest();
    }
}