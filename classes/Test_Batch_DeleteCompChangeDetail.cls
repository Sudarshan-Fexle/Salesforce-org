/**
     * Purpose         :   Test Class is written for code coverage Test_Batch_DeleteCompChangeDetail Class
     * 
     * Created By      :   Dipesh Gupta
     * 
     * Created Date    :   30/01/2020
     * 
     * Revision Log    :   V_1.0 - Created - Dipesh Gupta
     *			   V_1.1 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
     * 
     **/


@isTest(seeAllData = false)
public class Test_Batch_DeleteCompChangeDetail {
	
    @testSetup static void dataSetup()
    {
        test.startTest();
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
        
        // Release
        SFDC_Release__c rel = new SFDC_Release__c();
        rel.Name = 'Tst_MS';
        rel.Status__c = 'Scheduled - Planned';
        rel.Ready_for_Org_Comparison__c = true;
        rel.Last_Org_Comparision_Sync__c = System.today()-5;
        rel.Start_Date__c = System.today();
        rel.Org_Comparison_QA__c = conn[0].Id;
        rel.Org_Comparison_UAT__c = conn2[0].Id;
        rel.Environment_Manager__c = usr.Id;
        rel.Release_Manager__c = usr.Id;
        rel.Dev_Sandbox__c = devEnv[0].Id;
        rel.QA_Sandbox__c = devEnv2[1].Id;
        rel.UAT_Sandbox__c = devEnv2[1].Id;
        rel.Release_level__c = 'L2';
        insert rel;
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        List<SFDC_Release__c> relea = [Select Id,Org_Comparison_QA__c,Org_Comparison_UAT__c From SFDC_Release__c];
        System.assert(relea[0].Id != null);
        System.assert(relea.size() > 0);
        System.assert(relea[0].Org_Comparison_QA__c == conn[0].Id);
        System.assert(relea[0].Org_Comparison_UAT__c == conn2[0].Id);
        //===================================================
        
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
        
        //Component_Changes_Detail__c 2
        Component_Changes_Detail__c compChangeDetail2 = new Component_Changes_Detail__c();
        compChangeDetail2.Name = 'CompoChangeTest';
        compChangeDetail2.Type__c = 'Apex Class';
        compChangeDetail2.Type_Of_Mod__c = 'Add';
        compChangeDetail2.Last_Modified_Date__c = System.today()-4;
		compChangeDetail2.Last_Modified_By_Name__c = 'Testing';        
        compChangeDetail2.Org_Comparison__c = listOfOrgComp[1].Id;
        insert compChangeDetail2;
        
        List<Component_Changes_Detail__c> listOfComChangeDetail2 = [Select Id,Org_Comparison__c From Component_Changes_Detail__c];
        System.assert(listOfComChangeDetail2.size() > 0);
        System.assert(listOfComChangeDetail2[0].Id != null);
        System.assertEquals(listOfOrgComp[1].Id, listOfComChangeDetail2[1].Org_Comparison__c);
        
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test Batch_DeleteComChangeDetail class
     * 
     **/
    static testMethod void test_Batch_DeleteComChangeDetail()
    {
        
        
        Set<Id> setOfOrgCom = new Set<Id>();
        for(Org_Comparision__c oc : [Select Id From Org_Comparision__c]){
            setOfOrgCom.add(oc.Id);
        }
        
        test.startTest();
        Batch_DeleteCompChangeDetail bat = new Batch_DeleteCompChangeDetail (setOfOrgCom, true);
        database.executeBatch(bat,200) ;
        
        Batch_DeleteCompChangeDetail bat1 = new Batch_DeleteCompChangeDetail (setOfOrgCom, false);
        database.executeBatch(bat,200) ;
        test.stopTest();
        
        List<Component_Changes_Detail__c> listOfComChangeDetail = [Select Id,Org_Comparison__c From Component_Changes_Detail__c];
        System.assert(listOfComChangeDetail.size() <= 0);
    }
}