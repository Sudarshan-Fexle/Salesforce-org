/**
 *	Description		:	The test class to test the functionalities of AttributesChangeRequestExtension class
 *
 *	Created by		:	Mahendra Swarnkar
 * 
 * 	Created Date		:	07/09/2021
 * 
 * 	Revision Log		:	V1.0 Created - CR-20211005-15489
 *						
 **/
@isTest(seeAllData = false)
private class Test_AttributesChangeRequestExtension {
    
    @testSetup
    static void setupDate(){
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // Create a new User
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
        
        //Grab the Sandbox Series record type id so we can create one of those first to satisfy the lookup requirement for our other two Environments
        Id SandboxSeriesRecordTypeid = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        
        //create environment records
        List<IS_Environment__c> listEnvironments = new List<IS_Environment__c> ();
        listEnvironments.add(new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test2', RecordTypeId = SandboxSeriesRecordTypeid));
        listEnvironments.add(new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test3', RecordTypeId = SandboxSeriesRecordTypeid));
        
        insert listEnvironments;
        
        //Create a Release Record
        SFDC_Release__c release = new SFDC_Release__c (Name = 'Test1', Dev_Sandbox__c = listEnvironments[0].Id, QA_Sandbox__c = listEnvironments[0].Id, UAT_Sandbox__c = listEnvironments[1].Id, Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Release_level__c = 'L2');
        insert release;
        
        
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo',
                                                               Release__c = release.Id);
        insert cr;
        
        List<IS_System_Component__c> listComponents = new List<IS_System_Component__c>();
        listComponents.add(new IS_System_Component__c(Name = 'will auto-populate', Object_Label__c = 'Account', Object_API_Name__c = 'Account',
                                                      Object_Type__c = 'Object', SOX_Object__c = TRUE, Integration_Use__c = True, 
                                                      Managed_Package_Related__c = True, ES_Marketing_Related__c = True, 
                                                      ES_Core_Related__c = True, Xactly_Integration__c = True, Integration_Details__c = 'Test' ));
        
        listComponents.add(new IS_System_Component__c(Name = 'will auto-populate', Object_Label__c = 'Contact', Object_API_Name__c = 'Contact',
                                                      Object_Type__c = 'Object', SOX_Object__c = FALSE, Integration_Use__c = True, 
                                                      Managed_Package_Related__c = True, ES_Marketing_Related__c = True, 
                                                      ES_Core_Related__c = True, Xactly_Integration__c = True, Integration_Details__c = 'Test' ));
        
        insert listComponents;
        //SOX_Object__c, Integration_Use__c, Managed_Package_Related__c, High_Impact_Mod__c, Double_Deployment__c, Duplicate_Mod_on_CR__c, 
        //Duplicate_Mod_on_Release__c, ES_Marketing_Related__c, ES_Core_Related__c, Xactly_Related__c
        List<IS_System_Modification__c> listmodifications = new List<IS_System_Modification__c>();
        listmodifications.add(new IS_System_Modification__c(Change_Request__c = cr.Id, IS_System_Component__c = listComponents[0].Id, Include_in_Change_Set__c = true,
                                                            Type_Of_Modification__c = 'Modify', Deployed_To__c = 'QA', SOX_Object__c = True, 
                                                            High_Impact_Mod__c = false, Double_Deployment__c = false, Duplicate_Mod_on_CR__c = True, 
                                                            Duplicate_Mod_on_Release__c = True ));
        
        listmodifications.add(new IS_System_Modification__c(Change_Request__c = cr.Id, IS_System_Component__c = listComponents[0].Id, Include_in_Change_Set__c = true,
                                                            Type_Of_Modification__c = 'Modify', Deployed_To__c = 'QA', SOX_Object__c = True, 
                                                            High_Impact_Mod__c = false, Double_Deployment__c = false, Duplicate_Mod_on_CR__c = True, 
                                                            Duplicate_Mod_on_Release__c = True ));
        
        listmodifications.add(new IS_System_Modification__c(Change_Request__c = cr.Id, IS_System_Component__c = listComponents[1].Id, Include_in_Change_Set__c = true,
                                                            Type_Of_Modification__c = 'Modify', Deployed_To__c = 'QA', SOX_Object__c = False,
                                                            High_Impact_Mod__c = True, High_Impact_Mod_Type__c = 'Field Type Change', Double_Deployment__c = True, Duplicate_Mod_on_CR__c = false, 
                                                            Duplicate_Mod_on_Release__c = false, Deployment_Planning_Notes__c = 'Test')); 
        
        insert listmodifications;        
    }
    
    testMethod static void unitTest(){ 
        
        List<SFDC_Release__c> listRelease = [Select ID From SFDC_Release__c];
        List<SFDC_Change_Request__c> listCR = [Select ID From SFDC_Change_Request__c];
        Test.startTest();
        
        // set the page
        Test.setCurrentPage(Page.AttributesChangeRequest);
        
        //Standard Controller
        ApexPages.StandardController standardController = new ApexPages.StandardController(listRelease[0]);
        AttributesChangeRequestExtension attrCRExt = new AttributesChangeRequestExtension(standardController);
        
        System.assertEquals(attrCRExt.hasSOX, true);
        System.assertEquals(attrCRExt.hasIntegration, true);
        System.assertEquals(attrCRExt.hasHighImpact, true);
        System.assertEquals(attrCRExt.hasDoubleDeployment, true);
        System.assertEquals(attrCRExt.hasManagedPackage, true);
        System.assertEquals(attrCRExt.hasDuplicateModCR, true);
        System.assertEquals(attrCRExt.hasDuplicateModRelease, true);
        System.assertEquals(attrCRExt.hasESMarketing, true);
        System.assertEquals(attrCRExt.hasESCore, true);
        System.assertEquals(attrCRExt.hasXactlyMod, true);
        
        //Standard Controller
        standardController = new ApexPages.StandardController(listCR[0]); 
        attrCRExt = new AttributesChangeRequestExtension(standardController);
        
        System.assertEquals(attrCRExt.hasSOX, true);
        System.assertEquals(attrCRExt.hasIntegration, true);
        System.assertEquals(attrCRExt.hasHighImpact, true);
        System.assertEquals(attrCRExt.hasDoubleDeployment, true);
        System.assertEquals(attrCRExt.hasManagedPackage, true);
        System.assertEquals(attrCRExt.hasDuplicateModCR, true);
        System.assertEquals(attrCRExt.hasDuplicateModRelease, true);
        System.assertEquals(attrCRExt.hasESMarketing, true);
        System.assertEquals(attrCRExt.hasESCore, true);
        System.assertEquals(attrCRExt.hasXactlyMod, true);
        
        Test.stopTest();
    }
}