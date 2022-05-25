/**
 * Desription      :    test class for the SFDCModification class
 * 
 * Revision Logs   :    v1.0 - Victor Hanson - 11/11/2015 - Created
 *                      v1.1 - Jason Bennett - 12/01/2015 - Modified - added code to cover SOXObjectFieldUpdate method
 *                      v1.2 - Colin McGloin - 3/3/2016 - Modified to cover additional methods, added "See All Data = True" so that the Chatter Connect API could be tested - all data is still created as part of the test methods
 *                      V1.2 - Dipesh Gupta - 09/28/2016 - Modified By - Dipesh gupta - CR-20170907-11182 - added a new Flag to bypass dlrs. 
 *                      v1.3 - Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
 * 			v1.4 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564
**/
@isTest (seealldata=true)
public class Test_SFDCModification {
    
    static testmethod void testVerifyDeployedTo() {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        //V1.2
        Util.ByPassDLRSForTest = true;
        
        //Set up data as needed for the test class
        
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        
        insert cr;
        
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        
        IS_System_Component__c component2 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Contact',
                                                                       Object_API_Name__c = 'Contact',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = FALSE);
        
        insert component1;
        insert component2;
        
        
        IS_System_Modification__c modAcct = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        IS_System_Modification__c modCon = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component2.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        insert modAcct;
        insert modCon;
        
        CR_Action_Item__c actionItem1 = new CR_Action_Item__c(IS_System_Modification__c = modAcct.Id,
                                                              Timing__c = 'Post-Deployment',
                                                              Type__c = 'Configuration');
        
        actionItem1.Step_Complete_in_QA__c = 'No';
        actionItem1.Step_Complete_in_Rehearse__c = 'No';
        actionItem1.Step_Complete_in_Production__c = 'No';
        actionItem1.Step_Complete_in_Alternate__c = 'No';
        actionItem1.Step_Complete_in_UAT__c = 'No';
        
        CR_Action_Item__c actionItem2 = new CR_Action_Item__c(IS_System_Modification__c = modCon.Id,
                                                              Timing__c = 'Post-Deployment',
                                                              Type__c = 'Configuration');
        actionItem2.Step_Complete_in_QA__c = 'No';
        actionItem2.Step_Complete_in_Rehearse__c = 'No';
        actionItem2.Step_Complete_in_Production__c = 'No';
        actionItem2.Step_Complete_in_Alternate__c = 'No';
        actionItem2.Step_Complete_in_UAT__c = 'No';
        
        insert actionItem1;
        insert actionItem2;
        
        //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
        //Grab the Sandbox Series record type id so we can create one of those first to satisfy the lookup requirement for our other two Environments
        Id SandboxSeriesRecordTypeid = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        
        //create 3 environment records
        IS_Environment__c env1 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test2', RecordTypeId = SandboxSeriesRecordTypeid);
        IS_Environment__c env2 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test3', RecordTypeId = SandboxSeriesRecordTypeid);
        
        insert env1;
        insert env2;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
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
        
        //Create a Release Record
        SFDC_Release__c release1 = new SFDC_Release__c (Name = 'Test1', Dev_Sandbox__c = env1.Id, QA_Sandbox__c = env1.Id, UAT_Sandbox__c = env2.Id, Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Release_level__c = 'L2');
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 END HERE
        cr.Release__c = release1.Id;
        
        insert release1;
        update cr;
        
        modAcct.Deployed_To__c = 'QA;UAT';
        modCon.Deployed_To__c = 'QA;UAT';
        
          
        //Start test from here
        test.startTest();
      
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        string errorMsg;
        
        //try to update the mods and verify the error message is present
        try {
            update modCon;
        }
        catch(exception e) {
            errorMsg = e.getMessage();
        }
        system.assertNotEquals(null, errorMsg);
        
        //update the actionItem step completed field in Dev and QA
        actionItem2.Step_Complete_in_QA__c = 'Yes';
        actionItem2.Step_Complete_in_UAT__c = 'Yes';
        update actionItem2;
        
        //try to update the mods and verify the error message is present
        try {
            update modCon;
            update modAcct;
        }
        catch(exception e) {
            errorMsg = e.getMessage();
        }
        system.assertNotEquals(null, errorMsg);
        system.assertEquals(false, errorMsg.contains(actionItem2.Id));
        
        //Stop test here
        Test.stopTest();
        
        
        Util.ByPassDLRSForTest = false;
    }
    
    static testmethod void testdeleteISMod() {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        //V1.2 - Added By Dipesh Gupta
        Util.ByPassDLRSForTest = true;
        
        //Data setup for the test
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        
        insert cr;
        
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        
        insert component1;
        
        //Create new mod without CR Action Items
        
        IS_System_Modification__c mod3 = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       Deployed_To__c = 'QA',
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
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
        
        //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
        //Grab the ID to fulfill the Lookup filter requirements on IS Environment
        Id SalesforceEnvRTId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        
        /*IS_Environment__c ISEnv = new IS_Environment__c (Name = 'Test Environment',
                                                         RecordTypeId = SalesforceEnvRTId,
                                                         Status__c = 'Active',
                                                         Common_Name__c = 'Test Environment',
                                                         Environment_Type__c = 'Development');
        
        insert ISEnv;*/
               
        SFDC_Release__c deployedRelease = new SFDC_Release__c(Name='Test Release', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id, Release_level__c = 'L2');
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 END HERE
        
        insert deployedRelease;
        
        cr.Release__c = deployedRelease.Id;
        cr.Release_Change_Reason__c = 'Test';
        
        update cr;
        
       // insert mod3;
        
        //String to capture the error message which is sent back
        string errorMsg1;
        
        //Test 1 - Try to delete the mod and expect the error message to show correctly
        test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        try {
            delete mod3;
        }
        catch(exception e) {
            errorMsg1 = e.getMessage();
        }
        
        //V1.2
        Util.ByPassDLRSForTest = false;
        
        //Stop test here
        test.stopTest();
        
        //Asserting for the results
        system.assertNotEquals(null, errorMsg1);
       // system.assert(errorMsg1.contains(Label.ISModDeletion));
    }
    
    static testmethod void testCalculateManualMods() {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        //Initial Data Setup
        
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        
        insert cr;
        
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        
        IS_System_Component__c component2 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Contact',
                                                                       Object_API_Name__c = 'Contact',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = FALSE);
        
        insert component1;
        insert component2;
        
        
        IS_System_Modification__c modAcct = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        IS_System_Modification__c freshMod = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component2.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE,
                                                                       Order__c = 13);
        
        insert modAcct;
        insert freshMod;
        
        //Check the fields are blank as expected when a new mod is created
        
        system.assertEquals(False, freshMod.Has_Pre_Validation_Steps__c);
        system.assertEquals(False, freshMod.Has_Post_Deployment_Steps__c);
        system.assertEquals(False, freshMod.Has_Data_Modification__c);
        system.assertEquals(False, freshMod.Has_Manual_Step_s__c);
        system.assertEquals(False, freshMod.Has_Other_Deployment_Steps__c);
        system.assertEquals(null, freshMod.Pre_Validation_Estimate_Mins__c);
        system.assertEquals(null, freshMod.Pre_Deployment_Estimate_Mins__c);
        system.assertEquals(null, freshMod.Post_Deployment_Estimate_Mins__c);
        system.assertEquals(null, freshMod.Post_Deployment_Estimate_Mins__c);
        system.assertEquals(null, freshMod.Total_Manual_Steps_Estimate_Mins__c);
        
        //Create a couple of fresh Action Items
        List<CR_Action_Item__c> listCRAs = new List<CR_Action_Item__c>();
        
        CR_Action_Item__c actionItem1 = new CR_Action_Item__c(IS_System_Modification__c = modAcct.Id,
                                                              Timing__c = 'Post-Deployment',
                                                              Type__c = 'Configuration',
                                                              Time_Estimate_Mins__c = 100);
        
        CR_Action_Item__c actionItem2 = new CR_Action_Item__c(IS_System_Modification__c = modAcct.Id,
                                                              Timing__c = 'Pre-Validation',
                                                              Type__c = 'Data',
                                                              Time_Estimate_Mins__c = 300);
        
        CR_Action_Item__c actionItem3 = new CR_Action_Item__c(IS_System_Modification__c = freshMod.Id,
                                                              Timing__c = 'Pre-Deployment',
                                                              Type__c = 'Configuration',
                                                              Time_Estimate_Mins__c = 50.5);
        
        CR_Action_Item__c actionItem4 = new CR_Action_Item__c(IS_System_Modification__c = freshMod.Id,
                                                              Timing__c = 'Other',
                                                              Type__c = 'Data',
                                                              Time_Estimate_Mins__c = 23);
        
        listCRAs.add(actionItem1);
        listCRAs.add(actionItem2);
        listCRAs.add(actionItem3);
        listCRAs.add(actionItem4);
        //Start test from here
        test.startTest();
      
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Add the four Action Items and check to see if the checkboxes are populated as expected 
        //along with the time estimates rolling up
        /*
        insert actionItem1;
        insert actionItem2;
        insert actionItem3;
        insert actionItem4;
        */
        
        insert listCRAs;        

        IS_System_Modification__c checkValues1 = [SELECT Id, Deployed_To__c, Pre_Validation_Estimate_Mins__c, Pre_Deployment_Estimate_Mins__c, Post_Deployment_Estimate_Mins__c, Other_Manual_Steps_Estimate_Mins__c, Has_Pre_Validation_Steps__c, Has_Pre_Deployment_Steps__c, Has_Post_Deployment_Steps__c, Has_Other_Deployment_Steps__c, Has_Data_Modification__c, Total_Manual_Steps_Estimate_Mins__c
                                                    FROM IS_System_Modification__c WHERE Id = :modAcct.Id LIMIT 1];
        
        //Delete one of the Action Items and check to see the fields update and re-calculate
        delete actionItem2;
        
        IS_System_Modification__c checkValues2 = [SELECT Id, Deployed_To__c, Pre_Validation_Estimate_Mins__c, Pre_Deployment_Estimate_Mins__c, Post_Deployment_Estimate_Mins__c, Other_Manual_Steps_Estimate_Mins__c, Has_Pre_Validation_Steps__c, Has_Pre_Deployment_Steps__c, Has_Post_Deployment_Steps__c, Has_Other_Deployment_Steps__c, Has_Data_Modification__c, Total_Manual_Steps_Estimate_Mins__c
                                                    FROM IS_System_Modification__c WHERE Id = :modAcct.Id LIMIT 1];
        
        IS_System_Modification__c checkValues3 = [SELECT Id, Deployed_To__c, Pre_Validation_Estimate_Mins__c, Pre_Deployment_Estimate_Mins__c, Post_Deployment_Estimate_Mins__c, Other_Manual_Steps_Estimate_Mins__c, Has_Pre_Validation_Steps__c, Has_Pre_Deployment_Steps__c, Has_Post_Deployment_Steps__c, Has_Other_Deployment_Steps__c, Has_Data_Modification__c, Total_Manual_Steps_Estimate_Mins__c
                                                    FROM IS_System_Modification__c WHERE Id = :freshMod.Id LIMIT 1];
        
        //Stop test here
        test.stopTest();
        
        //Asserting for the results
        system.assertEquals(True, checkValues1.Has_Pre_Validation_Steps__c);
        system.assertEquals(True, checkValues1.Has_Post_Deployment_Steps__c);
        system.assertEquals(True, checkValues1.Has_Data_Modification__c);
        system.assertEquals(400, checkValues1.Total_Manual_Steps_Estimate_Mins__c);
        
        //Asserting for the results
        system.assertEquals(False, checkValues2.Has_Pre_Validation_Steps__c);
        system.assertEquals(True, checkValues2.Has_Post_Deployment_Steps__c);
        system.assertEquals(False, checkValues2.Has_Data_Modification__c);
        system.assertEquals(100, checkValues2.Total_Manual_Steps_Estimate_Mins__c);
        
        //Check Fractions calculate correctly
        system.assertEquals(True, checkValues3.Has_Pre_Deployment_Steps__c);
        system.assertEquals(True, checkValues3.Has_Other_Deployment_Steps__c);
        system.assertEquals(50.5, checkValues3.Pre_Deployment_Estimate_Mins__c);
        system.assertEquals(23, checkValues3.Other_Manual_Steps_Estimate_Mins__c);
        system.assertEquals(74, checkValues3.Total_Manual_Steps_Estimate_Mins__c);
    }
    
    static testmethod void testPreventFieldEdits() {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
        //Create data as needed for initial data setup
        
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        
        insert cr;
        
        
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        IS_System_Component__c component2 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Contact',
                                                                       Object_API_Name__c = 'Contact',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = FALSE);
        
        insert component1;
        insert component2;
        
        //get the modification
        IS_System_Modification__c modAcct = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        insert modAcct;
        
        //String to capture the error message which is sent back
        string errorMsg1;
        
        //Test 1 - Update the Mod without the Deployed To field set to 'UAT' or 'Rehearse' - Should succeed without issue
        
        modAcct.Dependency_Notes__c = 'Test1';
        modAcct.Description__c = 'Test1';
        modAcct.High_Impact_Mod_Type__c = 'Field Type Change';
        modAcct.Include_in_Change_Set__c = True;
        modAcct.New_Field_Length__c = 'Test1';
        modAcct.New_Field_Type__c = 'Test1';
        modAcct.New_Object_API_Name__c = 'Test1';
        modAcct.New_Object_Label__c = 'Test1';
        modAcct.Other_Configuration__c = 'Test1';
        
        try {
            update modAcct;
        }
        catch(exception e) {
            errorMsg1 = e.getMessage();
        }
        
        //Test 2 - Modify Update_Original_Steps_Redeploy__c to True and try changing the fields - should give an error back
        
        //get the modification
        IS_System_Modification__c modAcct2 = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        CR_Action_Item__c actionItem1 = new CR_Action_Item__c(IS_System_Modification__c = modAcct2.Id,
                                                              Timing__c = 'Post-Deployment',
                                                              Type__c = 'Configuration',
                                                              Time_Estimate_Mins__c = 100);
        
        insert modAcct2;
        insert actionItem1;
        
        actionItem1.Step_Complete_in_QA__c = 'Yes';
        actionItem1.Step_Complete_in_Rehearse__c = 'N/A';
        actionItem1.Step_Complete_in_Production__c = 'N/A';
        actionItem1.Step_Complete_in_Alternate__c = 'N/A';
        actionItem1.Step_Complete_in_UAT__c = 'Yes';
        actionItem1.Step_Complete_in_Dev__c = 'Yes';
        
        update actionItem1;
        
        //Modified by Mahaendra Swarnkar - CR-20190501-13061 - Spring cleanup
        //Grab the Sandbox Series record type id so we can create one of those first to satisfy the lookup requirement for our other two Environments
        Id SandboxSeriesRecordTypeid = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        
        //create 2 environment records
        IS_Environment__c env1 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test2', RecordTypeId = SandboxSeriesRecordTypeid);
        IS_Environment__c env2 = new IS_Environment__c (Name = 'Test3', Common_Name__c = 'Test3', RecordTypeId = SandboxSeriesRecordTypeid);
        
        insert env1;
        insert env2;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
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
        
        //Create a Release Record
        SFDC_Release__c release1 = new SFDC_Release__c (Name = 'Test1', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = env1.Id, UAT_Sandbox__c = env1.Id, QA_Sandbox__c = env1.Id, Release_level__c = 'L2');
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        insert release1;
        
        cr.Release__c = release1.Id;
        cr.Release_Change_Reason__c = 'Test';
        
        update cr;
        
        modAcct2.Update_Original_Steps_Redeploy__c = False;
        //modAcct2.Deployed_To__c = 'QA; UAT; Rehearse';
        
        update modAcct2;
        
        modAcct2.Dependency_Notes__c = 'Test2';
        modAcct2.Description__c = 'Test2';
        modAcct2.High_Impact_Mod_Type__c = 'Field Type Change1';
        modAcct2.Include_in_Change_Set__c = False;
        modAcct2.New_Field_Length__c = 'Test2';
        modAcct2.New_Field_Type__c = 'Test2';
        modAcct2.New_Object_API_Name__c = 'Test2';
        modAcct2.New_Object_Label__c = 'Test2';
        modAcct2.Other_Configuration__c = 'Test2';
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        try {
            update modAcct2;
        }
        catch(exception e) {
          //  system.assert(e.getMessage().contains(Label.ISModFieldEdits));//Checking the error message is displayed as expected
        }
        
        //Asserting for the results
        system.assertEquals(null, errorMsg1);
        
        Util.ByPassDLRSForTest = false;
        
        //Stop test here
        Test.stopTest();
    }
    
    /*static testmethod void testAddDeleteMention() {
        
        //Bypass DupeBlocker and triggers for test data creation
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        //V_1.2 - Dipesh Gupta
        Util.ByPassDLRSForTest = true;
            
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo');
        
        insert cr;
        
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'Account',
                                                                       Object_API_Name__c = 'Account',
                                                                       Object_Type__c = 'Object',
                                                                       SOX_Object__c = TRUE);
        
        insert component1;
        
        //Create the three users needed for the chatter post
        User user1 = TestUtilities.CreatenewUser(true);
        User user2 = TestUtilities.CreatenewUser(true);
        User user3 = TestUtilities.CreatenewUser(true);
        
        Id EmpRecordTypeid = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //Create the Contact needed for QA and associate a user with the Contact
        Contact leadQA = TestUtilities.CreateNewContact(true);
        leadQA.Employee_User_Record__c = user3.Id;
        leadQA.RecordTypeId = EmpRecordTypeid;
        
        Util.BypassAllTriggers = true;
        update leadQA;
        Util.BypassAllTriggers = false;
        
        //Create a new mod
        IS_System_Modification__c modAcct = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                       IS_System_Component__c = component1.Id,
                                                                       Type_Of_Modification__c = 'Modify',
                                                                       SOX_Object__c = FALSE);
        
        insert modAcct;
        
        //Create a Release Record and populate the right user fields
        SFDC_Release__c release1 = new SFDC_Release__c (Name = 'Test1', Environment_Manager__c = user1.Id, Release_Manager__c = user2.Id);
        
        insert release1;
        
        cr.IS_QA_Lead2__c = leadQA.Id;
        cr.Release__c = release1.Id;
        cr.Release_Change_Reason__c = 'Test';
        
        update cr;
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Test 1 - Kick off the chatter post process by updating it to Delete From Design
        modAcct.Delete_from_Design__c = True;
        update modAcct;
        
        //Stop Test from here
        Test.stopTest();
        
        //Querying for the "Feed Items"
        FeedItem chatterpost = [SELECT Id, Title, Type, Body FROM FeedItem WHERE ParentId = :modAcct.Id];
        
        //Assert for the results
        System.assert(chatterpost != null);
        system.assert(chatterpost.body.contains(System.Label.ChatterMentionDev));
        
        Util.ByPassDLRSForTest = false;
    }*/
}