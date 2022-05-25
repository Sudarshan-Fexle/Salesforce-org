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
@isTest(seeAllData = false)

private class Test_ReleaseTriggerHelper {
/**
      *   Purpose         :   Test class for ReleaseTriggerHelper
      *            
      *   Create By       :   Dipesh Gupta
      * 
      *   Created Date    :   12/17/2019
      *
      *   Revision Log    :   V_1.0 - Created - Dipesh Gupta
      * 		      V_1.1 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
      *   
      *   Coverage        :   V_1.0 -
      * 					   
      *
      **/
@testSetup static void dataSetup()
    {       
        //Query on RecordType
        List<RecordType> rt = [SELECT Id, DeveloperName FROM RecordType Where DeveloperName = 'EAB' LIMIT 1];
        System.assert(rt.size() > 0);
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
       User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = 'testing@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        // Connection__c 1
        Connection__c  connection = new Connection__c();
        connection.Name = 'Mods';
        insert connection;
        
        List<Connection__c> conn = [Select Id From Connection__c];
        System.assert(conn[0].Id != null);
        System.assert(conn.size() > 0);
        
        // Connection__c 2
        Connection__c  connection2 = new Connection__c();
        connection2.Name = 'Full 1';
        insert connection2;
        
        List<Connection__c> conn2 = [Select Id From Connection__c];
        System.assert(conn2[0].Id != null);
        System.assert(conn2.size() > 0);
        
        // Connection__c 3
        Connection__c  connection3 = new Connection__c();
        connection3.Name = 'Production';
        insert connection3;
        
        List<Connection__c> conn3 = [Select Id From Connection__c];
        System.assert(conn3[0].Id != null);
        System.assert(conn3.size() > 0);
        
        // Connection__c 4
        Connection__c  connection4 = new Connection__c();
        connection4.Name = 'Self Connection';
        insert connection4;
        
        List<Connection__c> conn4 = [Select Id From Connection__c];
        System.assert(conn4[0].Id != null);
        System.assert(conn4.size() > 0);
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
        // Release
        List<SFDC_Release__c> releaseData = new List<SFDC_Release__c>();
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_1',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = true,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
					     UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_2',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = false,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
					     UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_3',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = false,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
					     UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_4',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = true,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
					     UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_5',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = false,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
											 UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        releaseData.add(new SFDC_Release__c (OwnerId = usr.Id,
                                             Name = 'Test_6',
                                             Status__c = 'Scheduled - Planned',
                                             Start_Date__c = Date.newInstance(2019,17,12),
                                             Ready_for_Org_Comparison__c = false,
                                             Org_Comparison_QA__c = conn[0].Id,
                                             Org_Comparison_UAT__c = conn2[0].Id,
                                             Last_Org_Comparision_Sync__c = DateTime.newInstance(2019,12,6,0,0,0),
                                             Environment_Manager__c = usr.Id,
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
					     UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'));
        insert releaseData;
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        List<SFDC_Release__c> relea = [Select Id,Org_Comparison_QA__c,Org_Comparison_UAT__c From SFDC_Release__c];
        System.assert(relea[0].Org_Comparison_QA__c == conn[0].Id);
        System.assert(relea[0].Org_Comparison_UAT__c == conn2[0].Id);
        System.assertEquals(6, relea.size());
        
        
        
        // Org_Comparision__c 1
        Org_Comparision__c orgCom = new Org_Comparision__c();
        orgCom.Type__c = 'QA';
        orgCom.Release__c = relea[0].Id;
        orgCom.Create_Modifications_Manually__c = true;
        orgCom.Create_destructive_mods__c = true;
        orgCom.Create_Additive_Mods__c = true;
        orgCom.Last_Modified_Date_Bar__c = System.today();
        orgCom.Created_Date_Bar__c = System.today();
        orgCom.Component_Types__c = 'Apex Class;Apex Trigger;Approval Process;Button/Link;Custom Field;Custom Label;Custom Object;Custom Report Type;Email Template;Field Set;Group;Lightning Component Bundle;Lightning Page;List View;Page Layout;Permission Set;Process Builder Process;Profile;Record Type;Tab;Validation Rule;Visualforce Component;Visualforce Page;Workflow Email Alert;Workflow Field Update;Workflow Rule';
        orgCom.User_Filter__c = Label.Environment_Manager_Name+';Ketan Baluja;Karl Brenneman;Dipesh Gupta;Subhash Garhwal;Mahendra Swarnakar;Swetha Arolla;Taylor Wolfson;Abhinav Sharma;Colin McGloin;Victor Hanson'; 
        orgCom.Save_Mods_To_Different_Org__c = true;
        orgCom.Source_of_Truth__c = conn3[0].Id;
        orgCom.Comparison_Org__c = conn[0].Id;
        orgCom.Save_Mods_To__c = conn4[0].Id;
        insert orgCom;
        
        // Org_Comparision__c 2
        Org_Comparision__c orgCom2 = new Org_Comparision__c();
        orgCom2.Type__c = 'UAT';
        orgCom2.Release__c = relea[0].Id;
        orgCom2.Create_Modifications_Manually__c = true;
        orgCom2.Create_destructive_mods__c = true;
        orgCom2.Create_Additive_Mods__c = true;
        orgCom2.Last_Modified_Date_Bar__c = System.today();
        orgCom2.Created_Date_Bar__c = System.today();
        orgCom2.Component_Types__c = 'Apex Class;Apex Trigger;Approval Process;Button/Link;Custom Field;Custom Label;Custom Object;Custom Report Type;Email Template;Field Set;Group;Lightning Component Bundle;Lightning Page;List View;Page Layout;Permission Set;Process Builder Process;Profile;Record Type;Tab;Validation Rule;Visualforce Component;Visualforce Page;Workflow Email Alert;Workflow Field Update;Workflow Rule';
        orgCom2.User_Filter__c = Label.Environment_Manager_Name+';Ketan Baluja;Karl Brenneman;Dipesh Gupta;Subhash Garhwal;Mahendra Swarnakar;Swetha Arolla;Taylor Wolfson;Abhinav Sharma;Colin McGloin;Victor Hanson'; 
        orgCom2.Save_Mods_To_Different_Org__c = true;
        orgCom2.Source_of_Truth__c = conn3[0].Id;
        orgCom2.Comparison_Org__c = conn[0].Id;
        orgCom2.Save_Mods_To__c = conn4[0].Id;
        insert orgCom2;
        
        List<Org_Comparision__c> listOfOrgComp = [Select Id,Release__c From Org_Comparision__c];
        System.assert(listOfOrgComp.size() >= 2);
        System.assert(listOfOrgComp[0].Id != null);
        System.assertEquals(relea[0].id, listOfOrgComp[0].Release__c);
        
        //Component_Changes_Detail__c
        Component_Changes_Detail__c compChangeDetail = new Component_Changes_Detail__c();
        compChangeDetail.Name = 'CompoChangeTest';
        compChangeDetail.Type__c = 'Apex Class';
        compChangeDetail.Type_Of_Mod__c = 'Add';
        compChangeDetail.Last_Modified_Date__c = System.today()-4;
		compChangeDetail.Last_Modified_By_Name__c = 'Testing';        
        compChangeDetail.Org_Comparison__c = listOfOrgComp[0].Id;
        insert compChangeDetail;
        
        List<Component_Changes_Detail__c> listOfComChangeDetail = [Select Id,Org_Comparison__c From Component_Changes_Detail__c];
        System.assert(listOfComChangeDetail.size() > 0);
        System.assert(listOfComChangeDetail[0].Id != null);
        System.assertEquals(listOfOrgComp[0].Id, listOfComChangeDetail[0].Org_Comparison__c);
        
        
    }
    
    // Test Method for ValidateAndUpdateReadForOrgComparisonStatus & onReleaseStatusChangeDeleteItsOrgCompRecordsWithChilds
    // (Update Status to Deployed, cancelled with Ready_for_Org_Comparison__c as true & false)
    static testMethod void testValidateAndUpdateReadForOrgComparisonStatusDeployed()
    {
        List<SFDC_Release__c> releaseRecordsAI = [SELECT Id, Name, Status__c, Start_Date__c, Ready_for_Org_Comparison__c,
                                                  Org_Comparison_QA__c, Org_Comparison_UAT__c, Last_Org_Comparision_Sync__c
                                                  FROM SFDC_Release__c];
        
       
       // Update Conditions
        test.startTest();
        releaseRecordsAI[0].Status__c = 'Deployed';
        releaseRecordsAI[1].Ready_for_Org_Comparison__c = false;
        releaseRecordsAI[1].Status__c = 'Deployed';
        releaseRecordsAI[2].Status__c = 'Deployed';
        releaseRecordsAI[3].Status__c = 'Cancelled';
        releaseRecordsAI[4].Ready_for_Org_Comparison__c = True;
        releaseRecordsAI[4].Status__c = 'Cancelled';
        releaseRecordsAI[5].Status__c = 'Cancelled';
        
        update releaseRecordsAI;
        
        // After Update Release Status Check
        List<SFDC_Release__c> releaseRecordsAU = [SELECT Id, Name, Status__c, Start_Date__c, Ready_for_Org_Comparison__c,
                                                  Org_Comparison_QA__c, Org_Comparison_UAT__c, Last_Org_Comparision_Sync__c
                                                  FROM SFDC_Release__c];
        
        /*System.assertEquals('Deployed', releaseRecordsAU[0].Status__c);
        System.assertEquals(False, releaseRecordsAU[0].Ready_for_Org_Comparison__c);
        System.assertEquals('Deployed', releaseRecordsAU[1].Status__c);
        System.assertEquals(False, releaseRecordsAU[1].Ready_for_Org_Comparison__c);
        System.assertEquals('Deployed', releaseRecordsAU[2].Status__c);
        System.assertEquals(False, releaseRecordsAU[2].Ready_for_Org_Comparison__c);
        System.assertEquals('Cancelled', releaseRecordsAU[3].Status__c);
        System.assertEquals(False, releaseRecordsAU[3].Ready_for_Org_Comparison__c);
        System.assertEquals('Cancelled', releaseRecordsAU[4].Status__c);
        System.assertEquals(False, releaseRecordsAU[4].Ready_for_Org_Comparison__c);
        System.assertEquals('Cancelled', releaseRecordsAU[5].Status__c);
        System.assertEquals(False, releaseRecordsAU[5].Ready_for_Org_Comparison__c);*/
        
        test.stopTest();
        
    }
    
    static testMethod void test_updatingTargetFields(){
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
        User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = Math.random()+'@abc.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
        //Bypassing triggers
        Util.ByPassDLRSForTest=True;
        Id eTechDevRTId = Util.RecordTypeId('SFDC_Release__c', 'eTech Dev');
        SFDC_Release__c release = new SFDC_Release__c();
        release.RecordTypeId = eTechDevRTId;
        release.Name = 'Test-Data';
        release.Status__c = 'Scheduled - Planned';
        release.Release_level__c = 'L2';
        release.Target_Release_Date__c = Date.newInstance(2019, 12, 30);
        release.Environment_Manager__c = usr.Id;
        release.Release_Manager__c = usr.Id;
        release.Dev_Sandbox__c = devEnv[0].Id;
        release.QA_Sandbox__c = devEnv2[1].Id;
        release.UAT_Sandbox__c = devEnv2[1].Id;
        insert release;
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        SFDC_Release__c rel = [SELECT Id, Design_Deadline__c, Target_Dev_Completion_Date__c, Target_QA_Completion_Date__c, Target_UAT_Completion_Date__c FROM SFDC_Release__c WHERE ID =: release.Id LIMIT 1];
    	System.assertEquals(Date.newInstance(2019, 12, 06), rel.Design_Deadline__c);
    	System.assertEquals(Date.newInstance(2019, 12, 13), rel.Target_Dev_Completion_Date__c);
    	System.assertEquals(Date.newInstance(2019, 12, 20), rel.Target_QA_Completion_Date__c);
    	System.assertEquals(Date.newInstance(2019, 12, 27), rel.Target_UAT_Completion_Date__c);
        
         //Updating new values
        release.Release_level__c = 'L1 Weekly';      
        update release;
        
        rel = [SELECT Id, Design_Deadline__c, Target_Dev_Completion_Date__c, Target_QA_Completion_Date__c, Target_UAT_Completion_Date__c FROM SFDC_Release__c WHERE ID =: release.Id LIMIT 1];
    	System.assertEquals(null, rel.Design_Deadline__c);
    	System.assertEquals(null, rel.Target_Dev_Completion_Date__c);
    	System.assertEquals(null, rel.Target_QA_Completion_Date__c);
    	System.assertEquals(null, rel.Target_UAT_Completion_Date__c);
        
        //Updating new values
        release.Release_level__c = 'L2';      
        update release;
        
        rel = [SELECT Id, Design_Deadline__c, Target_Dev_Completion_Date__c, Target_QA_Completion_Date__c, Target_UAT_Completion_Date__c FROM SFDC_Release__c WHERE ID =: release.Id LIMIT 1];
    	System.assertEquals(Date.newInstance(2019, 12, 06), rel.Design_Deadline__c);
    	System.assertEquals(Date.newInstance(2019, 12, 13), rel.Target_Dev_Completion_Date__c);
    	System.assertEquals(Date.newInstance(2019, 12, 20), rel.Target_QA_Completion_Date__c);
    	System.assertEquals(Date.newInstance(2019, 12, 27), rel.Target_UAT_Completion_Date__c);
        
         //Updating new values
        release.Target_Release_Date__c = null ;      
        update release;
        
        rel = [SELECT Id, Design_Deadline__c, Target_Dev_Completion_Date__c, Target_QA_Completion_Date__c, Target_UAT_Completion_Date__c FROM SFDC_Release__c WHERE ID =: release.Id LIMIT 1];
    	System.assertEquals(null, rel.Design_Deadline__c);
    	System.assertEquals(null, rel.Target_Dev_Completion_Date__c);
    	System.assertEquals(null, rel.Target_QA_Completion_Date__c);
    	System.assertEquals(null, rel.Target_UAT_Completion_Date__c);
        
    }
    
    /**
      *   Purpose         :   For "testing deleteCompChangeDetail" method
      *            
      *   Create By       :   Dipesh Gupta
      * 
      *   Created Date    :   1/30/2020
      **/    
    static testMethod void test_deleteCompChangeDetail(){
        
        List<SFDC_Release__c> releaseRecordsAI = [SELECT Id, Name, Status__c, Start_Date__c, Ready_for_Org_Comparison__c,
                                                  Org_Comparison_QA__c, Org_Comparison_UAT__c, Last_Org_Comparision_Sync__c
                                                  FROM SFDC_Release__c];
        
        releaseRecordsAI[0].Status__c = 'Deployed';
        Update releaseRecordsAI;
        
        List<SFDC_Release__c> releaseRecordsAI2 = [SELECT Id, Name, Status__c, Start_Date__c, Ready_for_Org_Comparison__c,
                                                  Org_Comparison_QA__c, Org_Comparison_UAT__c, Last_Org_Comparision_Sync__c
                                                  FROM SFDC_Release__c];
        
        System.assert(releaseRecordsAI2[0].Status__c == 'Deployed');
        System.assert(releaseRecordsAI2[0].Ready_for_Org_Comparison__c == false);
            
    }


}