/**
* Purpose		: Test class for CopyToClipboardController
*
* Create By		: Mahendra Swarnakar
*
* Created Date		: 11/23/2020
*
* Revision Log		: V_1.0 - Created - Mahendra Swanakar
*
* Coverage		: V_1.0 - 83%
*
**/
@isTest(seeAllData = false)
public class Test_CopyToClipboardController {
    
    @testSetup static void setup() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        //Create a PSA Project record
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        psaProject.pse__Region__c = globalRegion.Id;
        psaProject.CurrencyIsoCode = 'USD';
        psaProject.Capitalizable__c = true;
        psaProject.pse__Is_Active__c = true;
        psaProject.pse__Allow_Timecards_Without_Assignment__c = true;
        psaProject.pse__Billing_Type__c = '--None--';
        psaProject.pse__Closed_for_Time_Entry__c = false;
        insert psaProject;
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        insert projectTask;
        
    }
    
    @isTest static void testCopyCounterId() {
        Id projectTaskId = [Select Id from pse__Project_Task__c limit 1]?.Id;
        
        List<pse__Project_Task__c> projTask = CopyToClipboardController.copyCounterId(projectTaskId);
        System.assertEquals(true, String.isNotBlank(projTask[0].Counter_ID__c));
        System.assertEquals(true, String.isBlank(projTask[0].PageProof_Proof_URL__c));
    }
}