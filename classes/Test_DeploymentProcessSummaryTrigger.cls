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

/*
*    Description     :    The class is used to as test class for DeploymentProcessSummaryTriggerHelper for back sync records
*
*    Created By      :    Rajeev Jain
*
*    Created Date    :    8/20/2020
*
*    Revision Logs   :     V_1.0 - Created
            
*
*/
@isTest(seeAllData = false)
public class Test_DeploymentProcessSummaryTrigger { 
    
    /*  @description    :  Method to create test data for one click deployment
    *
    *  @args            :  none
    *
    *  @return          :  void
    *
    **/
    @testSetup static void setup() {
        
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        Util.BypassAllTriggers = true;
        
        //Set up org connector config Custom setting data
        Org_Connector_Config__c orgConfig = new Org_Connector_Config__c();
        orgConfig.SetupOwnerId = '00eC00000016HQP';
        orgConfig.Base_URL_Login__c = 'https://login.salesforce.com';
        orgConfig.Base_URL_Test__c = 'https://test.salesforce.com';
        orgConfig.Client_Id_URL__c  = 'response_type=code&client_id=';
        orgConfig.Client_Secret_Key__c = '8925104254922037428';
        orgConfig.Connection_Type_Self__c = 'Self';
        orgConfig.Consumer_Key__c = '3MVG9U_dUptXGpYIWl6U3CZVSnm328FAYkPepRbR.ssNcbdf35_nwe0VM9AhU5imA3lDtAiuRKQriLZ4IBPKR';    
        orgConfig.Login_Hint__c  = 'login_hint=';
        orgConfig.Oath_Token_Url__c = '.salesforce.com/services/oauth2/token';
        orgConfig.OAuth_URL__c = '/services/oauth2/authorize';
        orgConfig.OrgType_Production_developer__c = 'Production/Developer';
        orgConfig.Prompt_Encoded__c = 'prompt=login%20consent';
        orgConfig.Redirect_URI__c = 'redirect_uri=';
        orgConfig.Redirect_URL__c = 'https://orgconnector.herokuapp.com/createConnection?cs=hello'  ;
        orgConfig.Self_Connection__c = 'Self Connection';
        orgConfig.State_URI__c = 'state='; 
        insert orgConfig;
        
        //Set up OneClick custom settings data
        List<OneClick_Settings__c> customSettingsData = new List<OneClick_Settings__c>();
        OneClick_Settings__c customData = new OneClick_Settings__c();
        customData.Name = 'ApplicationPageName';
        customData.Value__c = '/apex/DeploymentWizard?deploymentId=';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'ClientId';
        customData.Value__c = '3MVG9U_dUptXGpYIWl6U3CZVSnm328FAYkPepRbR.ssNcbdf35_nwe0VM9AhU5imA3lDtAiuRKQriLZ4IBPKR';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'ClientSecret';
        customData.Value__c = '8925104254922037428';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'LocalConnectionName';
        customData.Value__c = 'Self Connection';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'PackageDeploymentEndPoint';
        customData.Value__c = 'https://retrievesalesforceorg.herokuapp.com/deployPackage?';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'PackageFileName';
        customData.Value__c = 'Package.xml';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'PackageRetrievalEndPoint';
        customData.Value__c = 'https://retrievesalesforceorg.herokuapp.com/retrievePackage?';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();        
        customData.Name = 'PackageValidationEndPoint';
        customData.Value__c = 'https://retrievesalesforceorg.herokuapp.com/validatePackage?';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'RedirectUrl';
        customData.Value__c = 'https://orgconnector.herokuapp.com/createConnection';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'RetrievedPackageName';
        customData.Value__c = 'RetrieveResults.zip';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'RunTestEndPoint';
        customData.Value__c = 'https://runtestclasses.herokuapp.com/runTestClasses?';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'TargetOrgBackupEndPoint';
        customData.Value__c = 'https://retrievesalesforceorg.herokuapp.com/retrieveTargetBackup?';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'TargetOrgRetrivalPackageName';
        customData.Value__c = 'TargetOrgBackup.zip';
        customSettingsData.add(customData);
        
        customData = new OneClick_Settings__c();
        customData.Name = 'RedirectToOrg';
        customData.Value__c = 'https://retrievesalesforceorg.herokuapp.com/redirectToOrg?';
        customSettingsData.add(customData);
        
        insert customSettingsData;
        
    
        list<IS_Environment__c> envs = new list<IS_Environment__c>();
        IS_Environment__c dev1 = new IS_Environment__c(name = 'Dev1',
                                                       Common_Name__c = 'Dev1',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId(),
                                                       Status__c = 'Active');
        envs.add(dev1);
        IS_Environment__c dev6 = new IS_Environment__c(name = 'Dev6',
                                                       Common_Name__c = 'Dev6',
                                                       RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId(),
                                                       Status__c = 'Active');
        envs.add(dev6);
        insert envs;
        
        
        list<IS_Environment__c> sandboxes = new list<IS_Environment__c>();
        IS_Environment__c sb_dev1 = new IS_Environment__c(name = 'Dev1',
                                                          RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                          Sandbox_Series__c = dev1.Id,
                                                          Status__c = 'Active' , Date_Refreshed__c = Date.today() - 60);
        sandboxes.add(sb_dev1);
        IS_Environment__c sb_dev6 = new IS_Environment__c(name = 'Dev6',
                                                          RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                          Sandbox_Series__c = dev6.Id,
                                                          Status__c = 'Active' , Date_Refreshed__c = Date.today() - 10);
        sandboxes.add(sb_dev6);
        insert sandboxes;
        
        createOverlappingData();
        
        
        
    }
    
    /*  @description    :  Method to create fate data for test class
    *
    *  @args            :  none
    *
    *  @return          :  void
    *
    **/
    private static void createOverlappingData(){
        
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
       
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
        
        //Grab the Sandbox Series record type id so we can create one of those first to satisfy the lookup requirement for our other two Environments
        Id SandboxSeriesRecordTypeid = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        
        //create 3 environment records
        IS_Environment__c env1 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test2', RecordTypeId = SandboxSeriesRecordTypeid);
        IS_Environment__c env2 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test3', RecordTypeId = SandboxSeriesRecordTypeid);
        
        insert env1;
        insert env2;
        
        list<IS_Environment__c> sandboxes = new list<IS_Environment__c>();
        IS_Environment__c sb_dev1 = new IS_Environment__c(name = 'Dev1',
                                                          RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                          Sandbox_Series__c = env1.Id,
                                                          Status__c = 'Active' , Date_Refreshed__c = Date.today() - 60);
        sandboxes.add(sb_dev1);
        IS_Environment__c sb_dev6 = new IS_Environment__c(name = 'Dev6',
                                                          RecordTypeId = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Salesforce Sandbox').getRecordTypeId(),
                                                          Sandbox_Series__c = env2.Id,
                                                          Status__c = 'Active' , Date_Refreshed__c = Date.today() - 10);
        sandboxes.add(sb_dev6);
        insert sandboxes;
        
        //Create a Release Record
        SFDC_Release__c release1 = new SFDC_Release__c (Name = 'Overlapping Release1', Dev_Sandbox__c = sandboxes[0].Id, QA_Sandbox__c = sandboxes[0].Id, UAT_Sandbox__c = sandboxes[1].Id, Environment_Manager__c = usr.Id, Release_Manager__c = usr.Id, Release_level__c = 'L2',Status__c = 'Scheduled - Planned');
        insert release1;
        SFDC_Release__c release2 = new SFDC_Release__c (Name = 'Overlapping Release2', Dev_Sandbox__c = sandboxes[1].Id, QA_Sandbox__c = sandboxes[0].Id, UAT_Sandbox__c = sandboxes[1].Id, Environment_Manager__c = usr.Id, Release_Manager__c = usr.Id, Release_level__c = 'L2',Status__c = 'Scheduled - Planned');
        insert release2;
        
        //List to hold the CR
        List<SFDC_Change_Request__c> sfdcChangerequests = new List<SFDC_Change_Request__c>();
        
        SFDC_Change_Request__c cr = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo', Release__c = release1.Id);
        
        SFDC_Change_Request__c cr1 = new SFDC_Change_Request__c(Title__c = 'Demo Change Request1',
                                                                Request_Description__c = 'demo1',
                                                                Business_Justification__c = 'demo', Release__c = release1.Id);
        SFDC_Change_Request__c cr2 = new SFDC_Change_Request__c(Title__c = 'Demo Change Request',
                                                                Request_Description__c = 'demo',
                                                                Business_Justification__c = 'demo', Release__c = release2.Id);
        
        SFDC_Change_Request__c cr3 = new SFDC_Change_Request__c(Title__c = 'Demo Change Request1',
                                                                Request_Description__c = 'demo1',
                                                                Business_Justification__c = 'demo', Release__c = release2.Id);
        
        sfdcChangerequests.add(cr);
        sfdcChangerequests.add(cr1);
        sfdcChangerequests.add(cr2);
        sfdcChangerequests.add(cr3);
        
        insert sfdcChangerequests;
        
        //Creating the is system Component to create modifications 
        IS_System_Component__c component1 = new IS_System_Component__c(Name = 'will auto-populate',
                                                                       Object_Label__c = 'AccountTriggerHelper',
                                                                       Object_API_Name__c = 'AccountTriggerHelper',
                                                                       Object_Type__c = 'Apex Class',
                                                                       SOX_Object__c = false);
        
        //Inserting the components
        insert component1;
        
        //List to Hold the record types.
        List<RecordType> isSysCompRTypeId = [Select Id, RecordType.DeveloperName From RecordType 
                                             where sObjectType =: 'Is_System_Component__c' 
                                             AND RecordType.DeveloperName = : 'Configuration'];
        
        //Inserting the Parent Is System Component for Testing 
        Is_System_Component__c parentObjComp = new Is_System_Component__c( Name = 'Test Obj1', Object_Label__c = 'Institution', SOX_Object__c = true, 
                                                                          Object_API_Name__c = 'Account', Object_Type__c = 'Custom Object',
                                                                          RecordTypeId = isSysCompRTypeId[0].Id);
        Insert parentObjComp;
        
        //List to hold System component
        List<Is_System_Component__c> listIsSysComp = new List<Is_System_Component__c>();
        
        
        //Add record to list
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test1', Object_Label__c = 'Test', Custom__c = true,
                                                     Object_API_Name__c = 'Account', Object_Type__c = 'Custom Object',
                                                     SOX_Object__c = False, Parent__c = parentObjComp.Id, Data_Type__c = 'Custom Object',
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        //Add record to list
        listIsSysComp.add(new Is_System_Component__c( Name = 'TestOverlap', Object_Label__c = 'Test', Custom__c = true,
                                                     Object_API_Name__c = 'Account.Test__c', Object_Type__c = 'Custom Field',
                                                     SOX_Object__c = False, Parent__c = parentObjComp.Id, Data_Type__c = 'Checkbox',
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                     Object_API_Name__c = 'Account.Test1__c', Object_Type__c = 'Generic Object',
                                                     SOX_Object__c = true, Parent__c = parentObjComp.Id,
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                     Object_API_Name__c = '/TestReport__C', Object_Type__c = 'Dashboard/',
                                                     SOX_Object__c = true, Parent__c = parentObjComp.Id,
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                     Object_API_Name__c = 'Test List View', Object_Type__c = 'List View',
                                                     SOX_Object__c = true, Parent__c = parentObjComp.Id,
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                     Object_API_Name__c = 'VR_Test', Object_Type__c = 'Validation Rule',
                                                     SOX_Object__c = true, Parent__c = parentObjComp.Id,
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                     Object_API_Name__c = 'WR_Test', Object_Type__c = 'Workflow Rule',
                                                     SOX_Object__c = true, 
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test2', Custom__c = true,
                                                     Object_API_Name__c = 'Document_Test', Object_Type__c = 'Document',
                                                     SOX_Object__c = true, 
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test2', Custom__c = true,
                                                     Object_API_Name__c = 'Test2/Document_Test', Object_Type__c = 'Document',
                                                     SOX_Object__c = true, 
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test2', Custom__c = true,
                                                     Object_API_Name__c = 'Test2/Report_Test', Object_Type__c = 'Report',
                                                     SOX_Object__c = true, 
                                                     RecordTypeId = isSysCompRTypeId[0].Id
                                                    ));
        
        //Insert System component
        insert listIsSysComp;
        
        //List to hold the is system Modifications 
        List<IS_System_Modification__c> modifications = new List<IS_System_Modification__c>();
        
        //Creating Same type of modification on both CRs to create the overlapping
        IS_System_Modification__c modAcct = new IS_System_Modification__c(Change_Request__c = cr.Id,
                                                                          IS_System_Component__c = component1.Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct1 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = component1.Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct2 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = parentObjComp.Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct3 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[0].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct4 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[1].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        
        IS_System_Modification__c modAcct5 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[2].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        IS_System_Modification__c modAcct6 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[3].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        IS_System_Modification__c modAcct7 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[4].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        IS_System_Modification__c modAcct8 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[5].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        IS_System_Modification__c modAcct9 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                           IS_System_Component__c = listIsSysComp[6].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        IS_System_Modification__c modAcct10 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                            IS_System_Component__c = listIsSysComp[7].Id,
                                                                            Type_Of_Modification__c = 'Modify',
                                                                            SOX_Object__c = FALSE,
                                                                            Include_in_Change_Set__c = true,
                                                                            Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct11 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                            IS_System_Component__c = listIsSysComp[8].Id,
                                                                            Type_Of_Modification__c = 'Modify',
                                                                            SOX_Object__c = FALSE,
                                                                            Include_in_Change_Set__c = true,
                                                                            Potential_Overlapping__c = true);
        
        IS_System_Modification__c modAcct12 = new IS_System_Modification__c(Change_Request__c = cr1.Id,
                                                                            IS_System_Component__c = listIsSysComp[9].Id,
                                                                            Type_Of_Modification__c = 'Modify',
                                                                            SOX_Object__c = FALSE,
                                                                            Include_in_Change_Set__c = true,
                                                                            Potential_Overlapping__c = true);

        modifications.add(modAcct1);
        modifications.add(modAcct);
        modifications.add(modAcct2);
        modifications.add(modAcct3);
        modifications.add(modAcct4);
        modifications.add(modAcct5);
        modifications.add(modAcct6);
        modifications.add(modAcct7);
        modifications.add(modAcct8);
        modifications.add(modAcct9);
        modifications.add(modAcct10);
        modifications.add(modAcct11);
        modifications.add(modAcct12);
        insert modifications;
        //List to hold the is system Modifications 
        List<IS_System_Modification__c> modifications1 = new List<IS_System_Modification__c>();
        
        //Creating Same type of modification on both CRs to create the overlapping
        IS_System_Modification__c modifs = new IS_System_Modification__c(Change_Request__c = cr2.Id,
                                                                         IS_System_Component__c = component1.Id,
                                                                         Type_Of_Modification__c = 'Modify',
                                                                         SOX_Object__c = FALSE,
                                                                         Include_in_Change_Set__c = true,
                                                                         Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs1 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = component1.Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs2 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = parentObjComp.Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs3 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[0].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs4 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[1].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        
        
        IS_System_Modification__c modifs5 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[2].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        IS_System_Modification__c modifs6 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[3].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        IS_System_Modification__c modifs7 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[4].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        IS_System_Modification__c modifs8 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[5].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        IS_System_Modification__c modifs9 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                          IS_System_Component__c = listIsSysComp[6].Id,
                                                                          Type_Of_Modification__c = 'Modify',
                                                                          SOX_Object__c = FALSE,
                                                                          Include_in_Change_Set__c = true,
                                                                          Potential_Overlapping__c = true);
        IS_System_Modification__c modifs10 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                           IS_System_Component__c = listIsSysComp[7].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs11 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                           IS_System_Component__c = listIsSysComp[8].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        
        IS_System_Modification__c modifs12 = new IS_System_Modification__c(Change_Request__c = cr3.Id,
                                                                           IS_System_Component__c = listIsSysComp[9].Id,
                                                                           Type_Of_Modification__c = 'Modify',
                                                                           SOX_Object__c = FALSE,
                                                                           Include_in_Change_Set__c = true,
                                                                           Potential_Overlapping__c = true);
        modifications1.add(modifs1);
        modifications1.add(modifs);
        modifications1.add(modifs2);
        modifications1.add(modifs3);
        modifications1.add(modifs4);
        modifications1.add(modifs5);
        modifications1.add(modifs6);
        modifications1.add(modifs7);
        modifications1.add(modifs8);
        modifications1.add(modifs9);
        modifications1.add(modifs10);
        modifications1.add(modifs11);
        modifications1.add(modifs12);
        insert modifications1;
        
        Deployment_Track__c dTrack = testUtilities.CreateNewDeploymentTrack(false);
        dTrack.Deployment_Release_Project__c = release1.Id;
        dTrack.Available_for_Back_Sync__c = true;
        insert dTrack;
    }
    
    /*  @description    :  Method to automate logic for back sync summary records
    *
    *  @args            :  none
    *
    *  @return          :  void
    *
    **/
    static testMethod void testCheckProcessSummaryUpdates(){
        
        //Setup connection custom Object data
        List<Connection__c>  conData = new List<Connection__c>();
        
        Connection__c con = new Connection__c();
        con.Name = 'Self Connection';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        con.Sandbox_Type__c = 'Full';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 1';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        con.Sandbox_Type__c = 'Full';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 2';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        con.Sandbox_Type__c = 'Full';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 3';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        con.Sandbox_Type__c = 'Full';
        conData.add(con);
        
        insert conData;
        
        //To hold main deployment track records
        List<Deployment_Track__c> dTracks = [SELECT ID FROM Deployment_Track__c];
        dTracks[0].Source_Org__c = conData[0].Name;
        dTracks[0].Target_Org__c = conData[1].Name;
        update dTracks[0];
     
        Test.startTest();
        
        //To hold deployment process summary record for package retrivel of main deployment
        Deployment_Process_Summary__c packageRetrivelSummary = testUtilities.CreateNewDeploymentProcessSummary('Package_Retrieval_Summary','','','Started',false);
        packageRetrivelSummary.Deployment_Track__c = dTracks[0].Id;
        insert packageRetrivelSummary;
       
        //Add attachment under package retrivel summary record
        Attachment attachment = new Attachment();
        String zipFileName = 'RetrievalResult.zip';
        String zipContent = 'abc';

        attachment.Body = Blob.valueOf('abc');
        attachment.ContentType = 'application/zip';
        attachment.Name = String.valueOf('RetrievalResult.zip');
        attachment.ParentId = packageRetrivelSummary.id; 
        insert attachment;
        
        //To set status 'completed' for package retrival summary
        List<Deployment_Process_Summary__c> packageToBeUpdatedWithCompleted = [SELECT ID, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Id =: packageRetrivelSummary.Id ];
        packageToBeUpdatedWithCompleted[0].Status__c = 'Completed';
        update packageToBeUpdatedWithCompleted[0]; 
        
        //To hold crosscheck summary record of main deployment
        Deployment_Process_Summary__c crosscheckSummary = testUtilities.CreateNewDeploymentProcessSummary('Crosscheck_Summary','','','Started',false);
        crosscheckSummary.Deployment_Track__c = dTracks[0].Id;
        insert crosscheckSummary;
       
        //Add attachment under crosscheck summary record
        attachment = new Attachment();
        attachment.Body = Blob.valueOf('abc');
        attachment.ContentType = 'application/zip';
        attachment.Name = String.valueOf('RetrievalResult.zip');
        attachment.ParentId = crosscheckSummary.id; 
        insert attachment;
        
        //To set status 'Completed' for crosscheck summary record
        List<Deployment_Process_Summary__c> crosscheckToBeUpdatedWithCompleted = [SELECT ID, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Id =: crosscheckSummary.Id ];
        crosscheckToBeUpdatedWithCompleted[0].Status__c = 'Completed';
        update crosscheckToBeUpdatedWithCompleted[0];  
        
        //To hold validation summary record of main deployment
        Deployment_Process_Summary__c validationSummary = testUtilities.CreateNewDeploymentProcessSummary('Validation_Summary','','','Started',false);
        validationSummary.Deployment_Track__c = dTracks[0].Id;
        insert validationSummary;
        
        //To set status 'In Progress' for validation summary record
        List<Deployment_Process_Summary__c> valSummaryToBeUpdatedWithInProgress = [SELECT ID, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Id =: validationSummary.Id ];
        valSummaryToBeUpdatedWithInProgress[0].Status__c = 'In Progress';
        update valSummaryToBeUpdatedWithInProgress[0];
        
        //To set status 'Completed' for validation summary record
        List<Deployment_Process_Summary__c> valSummaryToBeUpdatedWithCompleted = [SELECT ID, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Id =: validationSummary.Id ];
        valSummaryToBeUpdatedWithCompleted[0].Status__c = 'Completed';
        valSummaryToBeUpdatedWithCompleted[0].Validation_Status__c = 'Pass';
        update valSummaryToBeUpdatedWithCompleted[0];
        
        //To hold deployment summary record of main deployment
        Deployment_Process_Summary__c deploymentSummary = testUtilities.CreateNewDeploymentProcessSummary('Deployment_Summary','','','Started',false);
        deploymentSummary.Deployment_Track__c = dTracks[0].Id;
        insert deploymentSummary;
       
        test.stopTest();
        
        //To get validation type back sync records
        List<Deployment_Track__c>  validationDTForBackSync = [SELECT Id, Name, Deployment_Process__c
                                              FROM Deployment_Track__c 
                                              WHERE  Deployment_Process__c = 'Validation'];
        
        //Assert for back sync records for validation 
        System.assertEquals(true, validationDTForBackSync.size() > 0);
        
        //To hold validation type summary records
        List<Deployment_Process_Summary__c> validationForbackSync = [SELECT ID, Status__c, Validation_Status__c, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Deployment_Track__c != null AND Deployment_Track__c =: validationDTForBackSync[0].Id AND Status__c = 'Started' AND Deployment_Track__r.Deployment_Process__c = 'Validation' ];
        List<Deployment_Process_Summary__c> validationToBeUpdateForBackSync = new List<Deployment_Process_Summary__c>();
        
        for(Deployment_Process_Summary__c sVForBackSync : validationForbackSync){
            sVForBackSync.Status__c = 'Completed' ;
            sVForBackSync.Validation_Status__c = 'Pass';
            validationToBeUpdateForBackSync.add(sVForBackSync);
        }
        //To update status of back sync records
        update validationToBeUpdateForBackSync;
      
        //To update deployment summary record's status with completed
        List<Deployment_Process_Summary__c> deploymentSumToBeUpdatedWithCompleted = [SELECT ID, Deployment_Track__c FROM Deployment_Process_Summary__c WHERE Id =: deploymentSummary.Id ];
        deploymentSumToBeUpdatedWithCompleted[0].Status__c = 'Completed';
        deploymentSumToBeUpdatedWithCompleted[0].Deployment_Status__c = 'Pass';
        update deploymentSumToBeUpdatedWithCompleted[0];
        
    }  
}