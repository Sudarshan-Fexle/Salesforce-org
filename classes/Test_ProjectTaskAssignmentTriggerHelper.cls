/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
/**
*   Purpose         :   Test class for ProjectTaskAssignmentTriggerHelper.
*            
*   Create By       : 	Mahendra Swarnkar  
*
*   Created Date    :   11/04/2020
*
*   Revision Log    :   V1.0 - Created - CR-20201020-14618
* 
*   Coverage        :    
**/
@isTest(seeAllData = false)
public class Test_ProjectTaskAssignmentTriggerHelper {
	
    //Setup Test data to test the ProductConfiguratorController controller functionlaity
    @testSetup static void dataSetup() {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        //Util.byPassAllTriggers = true;
    }
    
    //Test method
    static testMethod void testCreateAssignmentForResourceProject() {
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        
         //Insert Permission Control
        pse__Permission_Control__c pControl = new pse__Permission_Control__c();
        pControl.pse__User__c = UserInfo.getUserId();
        pControl.pse__Region__c = globalRegion.Id;
        pControl.pse__Timecard_Entry__c = true;
        pControl.pse__Timecard_Ops_Edit__c = true;
        pControl.pse__Cascading_Permission__c = true;
        pControl.pse__Staffing__c = true;
        insert pControl;
        
        //Grab a Profile for our Test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Specialist'];
        User anakinSkywalker = testUtilities.CreateNewUser(p, true);
        anakinSkywalker.LastName = 'Skywalker';
        update anakinSkywalker;
        
        //Insert a Contact
        Contact psaResourceContact = TestUtilities.CreateNewContact(true);
        psaResourceContact.pse__Salesforce_User__c = anakinSkywalker.Id;
        psaResourceContact.pse__Is_Resource__c = true;
        psaResourceContact.pse__Is_Resource_Active__c = true;
        psaResourceContact.pse__Region__c = globalRegion.Id;
        update psaResourceContact;
        
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
        
        Datetime currentDateTime = system.now();
        Date currentDate = currentDateTime.date();
        
        //Insert the Project Task
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = psaProject.Id;
        projectTask.pse__Start_Date_Time__c = currentDateTime ;
        projectTask.pse__End_Date_Time__c = system.now().addDays(1);
        insert projectTask;
        
        //Insert Project Task Assignment record
        pse__Project_Task_Assignment__c projectTaskAssignment = new pse__Project_Task_Assignment__c();
        projectTaskAssignment.pse__Project_Task__c = projectTask.Id;
        projectTaskAssignment.pse__Resource__c = psaResourceContact.Id;
        
         //Start
        Test.StartTest();
        
        insert projectTaskAssignment;
        
        List<pse__Schedule__c> listschedules = [Select Id, pse__Start_Date__c, pse__End_Date__c, pse__Action_Force_Schedule_Refresh__c from pse__Schedule__c];
        
        //Assert
        System.assertEquals(1, listschedules.size());
        //System.assertEquals(true, listschedules[0].pse__Action_Force_Schedule_Refresh__c);
        System.assertEquals(currentDate, listschedules[0].pse__Start_Date__c);
        System.assertEquals(currentDate.addDays(1), listschedules[0].pse__End_Date__c);
        
        List<pse__Assignment__c> listAssignments = [Select Id, pse__Status__c, pse__Schedule__c, pse__Is_Billable__c from pse__Assignment__c where pse__Resource__c =: psaResourceContact.Id AND pse__Project__c =: psaProject.Id];
        
        //Assert
        System.assertEquals(1, listAssignments.size());
        System.assertEquals(listschedules[0].Id, listAssignments[0].pse__Schedule__c);
        
        //Stop
        Test.StopTest();
    }
}