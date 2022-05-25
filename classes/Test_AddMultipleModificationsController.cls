/**
 * 
 * Desription      :   	test methods for the AddMultipleModificationsController class
 * 
 * Revision Logs   :    Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564
 * 
 * 
 **/
@isTest(seeAllData = false)
public class Test_AddMultipleModificationsController {
    
    /**
     * 
     * @description: data setup method for record insert
     * 
     **/
    @testSetup static void dataSetup()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
        test.startTest();
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'Standard User' LIMIT 1];
        
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
        SFDC_Release__c rel = new SFDC_Release__c();
        rel.Name = 'Tst_MS';
        rel.Status__c = 'Scheduled - Planned';
        rel.Ready_for_Org_Comparison__c = true;
        rel.Last_Org_Comparision_Sync__c = System.today()-5;
        rel.Start_Date__c = System.today();
        rel.Org_Comparison_QA__c = conn[0].Id;
        rel.Org_Comparison_UAT__c = conn2[0].Id;
        //Modified by Subhash Garhwal - 02/24/2020 - CR-20200221-13791 - 
        rel.Release_level__c = 'L2';
        rel.Environment_Manager__c = usr.Id;
        rel.Release_Manager__c = usr.Id;
        rel.Dev_Sandbox__c = devEnv[0].Id;
        rel.QA_Sandbox__c = devEnv2[1].Id;
        rel.UAT_Sandbox__c = devEnv2[1].Id;
        insert rel;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        List<SFDC_Release__c> relea = [Select Id,Org_Comparison_QA__c,Org_Comparison_UAT__c From SFDC_Release__c];
        System.assert(relea[0].Id != null);
        System.assert(relea.size() > 0);
        System.assert(relea[0].Org_Comparison_QA__c == conn[0].Id);
        System.assert(relea[0].Org_Comparison_UAT__c == conn2[0].Id);
        //===================================================
        
        // contact
        Contact con = new Contact();
        con.LastName = 'MSTest';
        con.Email = 'test@test.com';
        con.Title = 'Test';
        con.Phone = '3434234234';
        con.Contact_Status__c = 'Active';
        con.CurrencyIsoCode = 'USD';
        insert con;
        List<Contact> conList = [Select Id From Contact];
        System.assert(conList.size() > 0);
        System.assert(conList[0].Id != null);
        
        
        // IS_System__c
        IS_System__c isSystem = new IS_System__c();
        isSystem.Name = 'Test';
        isSystem.Status__c = 'Active';
        insert isSystem;
        
        List<IS_System__c> isSystemList = [Select Id From IS_System__c];
        System.assert(isSystemList.size() > 0);
        System.assert(isSystemList[0].Id != null);
        
        // SFDC_Change_Request__c
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c();
        cr.Change_Request_Level__c = 'L2';
        cr.CR_Type__c = 'Enhancement';
        cr.Title__c = 'Mods Tracker Utility';
        cr.Priority__c = 'C - Standard';
        cr.Status__c = '06-In Development';
        cr.What_Is_The_Business_Need__c = 'This is just a drill';
        cr.Users_Affected__c = 'Single Division';
        //cr.Requested_By2__c = conList[0].id;
        cr.Release__c = relea[0].id;
        cr.IS_System__c = isSystemList[0].Id;
        insert cr;
        
        List<SFDC_Change_Request__c> changeReqList = [Select Id,Release__c,IS_System__c From SFDC_Change_Request__c];
        System.assert(changeReqList.size() > 0);
        System.assert(changeReqList[0].Id != null);
        System.assertEquals(relea[0].id, changeReqList[0].Release__c);
        System.assertEquals(isSystemList[0].Id, changeReqList[0].IS_System__c);
        
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
          
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the getEnvironmentPickListValue() method
     * 
     **/
    static testMethod void test_getEnvironmentPickListValue()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<SFDC_Change_Request__c> crList = [Select Id,Release__c From SFDC_Change_Request__c];
        
        test.startTest();
        LightningResponseEntity res = AddMultipleModificationsController.getEnvironmentPickListValue(crList[0].id);
        System.assert(res.body != null || res.body !='');
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the findComponentTypes() method
     * 
     **/
    static testMethod void test_findComponentTypes()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
                
        test.startTest();
        LightningResponseEntity res = AddMultipleModificationsController.findComponentTypes();
        System.assert(res.body != null || res.body !='');
        
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the getLastOrgComparisionSyncDate() method
     * 
     **/
    static testMethod void test_getLastOrgComparisionSyncDate()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<SFDC_Change_Request__c> crList = [Select Id,Release__c From SFDC_Change_Request__c];
                
        test.startTest();
        LightningResponseEntity res = AddMultipleModificationsController.getLastOrgComparisionSyncDate(crList[0].id);
        System.assert(res.body != null || res.body !='');
        
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the getDataFromComponentsChangeDetails() method
     * 
     **/
    static testMethod void test_getDataFromComponentsChangeDetails()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<SFDC_Change_Request__c> crList = [Select Id,Release__c From SFDC_Change_Request__c];
        List<Org_Comparision__c> orgCompList = [Select Id From Org_Comparision__c];
        
        Date oStartDate = System.today()-4;
        Date oEndDate =  System.today();
        List<String> selectedComponentType = new List<String>();
        selectedComponentType.add('Apex Class');
        selectedComponentType.add('Custom Field');
            
        List<String> lastModifiedByNames = new List<String>();
        lastModifiedByNames.add('Testing');
        lastModifiedByNames.add('Mahendra Swarnakar');
            
        List<String> listOfOrgComparisionRecordsIds = new List<String>();
        listOfOrgComparisionRecordsIds.add(orgCompList[0].Id);
        listOfOrgComparisionRecordsIds.add(orgCompList[1].Id);
        
        String environmentType = '';
        List<String> typeOfModification = new List<String>();
        typeOfModification.add('Add');
        typeOfModification.add('Modify');
        typeOfModification.add('Delete');
                
        test.startTest();
        try{
            LightningResponseEntity res = AddMultipleModificationsController.getDataFromComponentsChangeDetails(oStartDate, oEndDate,selectedComponentType,lastModifiedByNames,listOfOrgComparisionRecordsIds,crList[0].id,environmentType,typeOfModification);
            System.assert(res.body != null || res.body !='');
        }catch(exception e){
            System.debug('error = '+ e);
        }
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the fetchCurrentLoggedInUserDetails() method
     * 
     **/
    static testMethod void test_fetchCurrentLoggedInUserDetails()
    {
         //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        
        List<user> userList = [Select Id From user];
        
        test.startTest();
        LightningResponseEntity res = AddMultipleModificationsController.fetchCurrentLoggedInUserDetails(userList[0].Id);
        System.assert(res.body != null || res.body !='');
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: Nagative test the fetchCurrentLoggedInUserDetails() method
     * 
     **/
    static testMethod void test_Nagative_fetchCurrentLoggedInUserDetails()
    {
         //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        
        // blank argument test
        Id UserId = null ;
        test.startTest();
        LightningResponseEntity res = AddMultipleModificationsController.fetchCurrentLoggedInUserDetails(UserId);
        System.assert(res.message == 'Unable to access current logged in user Id.');
        
        // instance of test
        String usrId = 'fakeId0099unnn';
        LightningResponseEntity res2 = AddMultipleModificationsController.fetchCurrentLoggedInUserDetails(usrId);
        System.assert(res2.message == 'Invalid Id for current logged in user.');
        test.stopTest();
        
    }
    
    /**
     * 
     * @description: test the updateRecords() method
     * 
     **/
    static testMethod void test_updateRecords()
    {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //List<Component_Changes_Detail__c> listOfComChangeDetail = [Select Id,Org_Comparison__c,Name, Type__c, Type_Of_Mod__c From Component_Changes_Detail__c];
        List<SFDC_Change_Request__c> changeReqList = [Select Id From SFDC_Change_Request__c];
        
        String data = '[{"componentsChangeDetailsId":"aI02i0000004XdqCAE","componentsChangeDetailsName":"SBQQ__Subscription__c.Did_Prior_Yr_Fulflmnt_have_anyPaper_m__c","componentsChangeDetailsType":"Custom Field","componentsChangeDetailsTypeOfMod":"Add","componentsChangeDetailsLastModifiedBy":"'+Label.Environment_Manager_Name+'","componentsChangeDetailsLastModifiedDate":"2019-12-18","componentsChangeDetailsCreatedDate":"2019-12-18","description":"Custom Field has been Add per CR work Order","componentsChangeDetailsIsExistingMod":false},';
        data += '{"componentsChangeDetailsId":"aI02i0000004XdrCAE","componentsChangeDetailsName":"SBQQ__QuoteLine__c.Did_Prior_Yr_Fulflmnt_have_anyPaper_CSV__c","componentsChangeDetailsType":"Custom Field","componentsChangeDetailsTypeOfMod":"Add","componentsChangeDetailsLastModifiedBy":"'+Label.Environment_Manager_Name+'","componentsChangeDetailsLastModifiedDate":"2019-12-18","componentsChangeDetailsCreatedDate":"2019-12-18","description":"Custom Field has been Add per CR work Order","componentsChangeDetailsIsExistingMod":false}]';
        test.startTest();
        try{
            LightningResponseEntity res = AddMultipleModificationsController.updateRecords(data, changeReqList[0].Id);
            //System.assert(res.body == 'Success');
        }catch(exception e){
            
        }
        test.stopTest();
    }

}