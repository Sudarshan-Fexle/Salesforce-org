/*
    Purpose:    This test class is to test ComponentChangesDetailTriggerHelper 
                
    Create By:  Fexle Technology
    
    Created Date:   04/09/2019
    
    Current Version:    v1.0
    			v1.1 Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564
    
    Created By:  Seemu Saikia 
	Modifeid On  : 04/26/2019 By : Seemu Saikia

	Modifeid On  : 01/17/2020 By : Dipesh Gupta  for increase code coverage and add asserts
*/

@isTest(seeAllData = false)
public class Test_ComponentChangesDetailTriggerHelper {

    static testMethod void testcheckISSystemComponent(){
         //Inserting CR
        SFDC_Change_Request__c changeRequests = new SFDC_Change_Request__c (Title__c = 'Test219');
        insert changeRequests;
        
        //Inserting Connections 
        Connection__c con1 = new Connection__c();
        con1.Name = 'Source of Truth';
        con1.Org_type__c = 'Sandbox';
        con1.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con1.Instance_URL__c = Url.getSalesforceBaseUrl().toExternalForm();
        insert con1;
        
        List<Connection__c> listOfConnection1 = [Select Id From Connection__c];
        System.assert(listOfConnection1[0].Id != null);
        System.assert(listOfConnection1.size() > 0);
        
        Connection__c con2 = new Connection__c();
        con2.Name = 'Comparison Org';
        con2.Org_type__c = 'Sandbox';
        con2.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con2.Instance_URL__c = Url.getSalesforceBaseUrl().toExternalForm();
        insert con2;
        
        List<Connection__c> listOfConnection2 = [Select Id From Connection__c];
        System.assert(listOfConnection2[0].Id != null);
        System.assert(listOfConnection2.size() > 0);
        
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
        rel.Org_Comparison_QA__c = con1.Id;
        rel.Org_Comparison_UAT__c = con2.Id;
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
        System.assert(relea[0].Org_Comparison_QA__c == con1.Id);
        System.assert(relea[0].Org_Comparison_UAT__c == con2.Id);
        
        //Inserting Org Comarison
        List<Org_Comparision__c> orgCon = new List<Org_Comparision__c>();
        orgCon.add(new Org_Comparision__c(Change_Request__c = changeRequests.id,
                                          Created_Date_Bar__c = date.today(),
                                          Type__c = 'QA',
                                          Release__c = rel.Id,
                                          Last_Modified_Date_Bar__c=date.today(),
                                          Source_of_Truth__c=con1.id,
                                          Comparison_Org__c=con2.id));
        
        orgCon.add(new Org_Comparision__c(Change_Request__c = changeRequests.id,
                                          Created_Date_Bar__c = date.today(),
                                          Type__c = 'QA',
                                          Release__c = rel.Id,
                                          Last_Modified_Date_Bar__c=date.today(),
                                          Source_of_Truth__c=con1.id,
                                          Comparison_Org__c=con2.id));
       	test.startTest();
        insert orgCon;
        
        List<Org_Comparision__c> listOfOrgComp = [Select Id,Release__c From Org_Comparision__c];
        System.assert(listOfOrgComp.size() > 0);
        System.assert(listOfOrgComp[0].Id != null);
        System.assertEquals(rel.Id, listOfOrgComp[0].Release__c);
        
        //creating new ComponentChangesDetail 1
        List<Component_Changes_Detail__c> listCCD = new List<Component_Changes_Detail__c>();
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Account.ActiveTest__c',Type_Of_Mod__c='Add',Type__c='Custom Field',Org_Comparison__c=orgCon[0].id,Last_Modified_By__c='005A0000008unZY',Created_By__c='005A0000008unZY'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Account.ShowActive',Type_Of_Mod__c='Modify',Type__c='Page Layouts',Org_Comparison__c=orgCon[0].id,Last_Modified_By__c='005A0000008unZY',Created_By__c='005A0000008unZY'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Contact.ActiveShow',Type_Of_Mod__c='Modify',Type__c='Record Type',Org_Comparison__c=orgCon[1].id,Last_Modified_By__c='005A0000008unZY',Created_By__c='005A0000008unZY'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Contact.Status',Type_Of_Mod__c='Add',Type__c='Apex Class',Org_Comparison__c=orgCon[1].id,Last_Modified_By__c='005A0000008unZY',Created_By__c='005A0000008unZY'));
		
		insert listCCD;
        
        List<Component_Changes_Detail__c> listOfComChangeDetail = [Select Id,Org_Comparison__c From Component_Changes_Detail__c];
        System.assert(listOfComChangeDetail.size() > 0);
        System.assert(listOfComChangeDetail[0].Id != null);
        System.assertEquals(orgCon[0].id, listOfComChangeDetail[0].Org_Comparison__c);
        
        //creating new ComponentChangesDetail 2
        List<Component_Changes_Detail__c> listCCD2 = new List<Component_Changes_Detail__c>();
        listCCD2.add(new Component_Changes_Detail__c(Full_Name__c = 'Account.ActiveTest__c',Type_Of_Mod__c='Modify',Type__c='Apex Class',Org_Comparison__c=orgCon[0].id,Last_Modified_By__c='005A0000008unZY',Created_By__c='005A0000008unZY'));
        insert listCCD2;
                
        test.stopTest();
        
        /*
        //creating new ComponentChangesDetail
        List<Component_Changes_Detail__c> listCCD = new List<Component_Changes_Detail__c>();
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Account.ActiveTest__c',Type_Of_Mod__c='Add',Type__c='Custom Field'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Account.ShowActive',Type_Of_Mod__c='Modify',Type__c='Page Layouts'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Contact.ActiveShow',Type_Of_Mod__c='Modify',Type__c='Record Type'));
        listCCD.add(new Component_Changes_Detail__c(Full_Name__c = 'Contact.Status',Type_Of_Mod__c='Add',Type__c='Apex Class'));
		test.startTest();
		insert listCCD;
        
        List<Component_Changes_Detail__c> listCCD2 = new List<Component_Changes_Detail__c>();
        //updating existing is system component
        listCCD2.add(new Component_Changes_Detail__c(Full_Name__c = 'Contact.Status',Type_Of_Mod__c='Modify',Type__c='Apex Class'));
        insert listCCD2;
		test.stopTest(); 
		       
        */
    }
}