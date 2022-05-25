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
*    Description     :    The class is used to as test class for Deployement Wizard controller 
*
*    Created By      :    Ishan Arora
*
*    Created Date    :    20/04/2018
*
*    Revision Logs   :     V_1.0 - Created
			   V_1.1 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
*
*/

@isTest(seeAllData = false)
public class Test_DeploymentWizardController { 
    
    
    @testSetup static void setup() {
        
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        Util.BypassAllTriggers = true;
        
        //Set up org connector config Custom setting data
        Org_Connector_Config__c orgConfig = new Org_Connector_Config__c();
        orgConfig.SetupOwnerId = '00eC00000016HQP';
        orgConfig.Base_URL_Login__c	= 'https://login.salesforce.com';
        orgConfig.Base_URL_Test__c = 'https://test.salesforce.com';
        orgConfig.Client_Id_URL__c	= 'response_type=code&client_id=';
        orgConfig.Client_Secret_Key__c = '8925104254922037428';
        orgConfig.Connection_Type_Self__c = 'Self';
        orgConfig.Consumer_Key__c = '3MVG9U_dUptXGpYIWl6U3CZVSnm328FAYkPepRbR.ssNcbdf35_nwe0VM9AhU5imA3lDtAiuRKQriLZ4IBPKR';	
        orgConfig.Login_Hint__c	 = 'login_hint=';
        orgConfig.Oath_Token_Url__c	= '.salesforce.com/services/oauth2/token';
        orgConfig.OAuth_URL__c = '/services/oauth2/authorize';
        orgConfig.OrgType_Production_developer__c = 'Production/Developer';
        orgConfig.Prompt_Encoded__c	= 'prompt=login%20consent';
        orgConfig.Redirect_URI__c = 'redirect_uri=';
        orgConfig.Redirect_URL__c = 'https://orgconnector.herokuapp.com/createConnection?cs=hello'	;
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
        
        //Setup connection custom Object data
        List<Connection__c>  conData = new List<Connection__c>();
        
        Connection__c con = new Connection__c();
        con.Name = 'Self Connection';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 1';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 2';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        conData.add(con);
        
        insert conData;
        
        
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
    *  @args           	:  none
    *
    *  @return         	:   void
    *
    **/
    private static void createOverlappingData(){
        
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        //V1.2
        Util.ByPassDLRSForTest = true;
        
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
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
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
        
    }
    
    
    /*  @description    :  Meathod to test OneClick deployment 
    *
    *  @args           	:  none
    *
    *  @return         	:   void
    *
    **/
    
    static testMethod void testDeploymentWizardApp(){
        
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        Test.startTest(); 
        
       // testValidateConnectionNegativeCase();
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMock());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        
         //System.assertEquals('Started',obj.deploymentTrack.Deployment_Progress__c);
       /* Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMock());  
        
        //Maintain state 
        obj.appProperties.appState = 'Env Setup';

        //Move wizard to next step( validate env settings for +ve case)
        obj.moveNext(); */
        
        //------------------TEST-RUN----------------
        
        //Method to evaluate test run functionality
        test_TestRunFunctionality(obj, modification);
        
        //-----------------Package retrieval ----------------
        
        Deployment_Process_Summary__c packageRetrievalprocessSummary = new Deployment_Process_Summary__c();
        testPackageRetrival(obj ,  packageRetrievalprocessSummary );
        test.stopTest();
        
        //-------------CrossCheck controller------------    
        Attachment attachment = new Attachment();
        testCrossCheckFunctionality(obj, packageRetrievalprocessSummary, attachment);
        
        //---------------validation -----------------     
           
        String reportURL ;
        testValidationFunctionality( obj,  attachment,  reportURL );
        
        
        //--------------deployment--------------
     
        Deployment_Process_Summary__c deploymentProcessSumary = new Deployment_Process_Summary__c();
        testDeploymentFuntionality( obj,deploymentProcessSumary,  attachment ,  reportURL);
        
        //-------------deployment summary ---------------------------
        
        testDeploymentSummaryFunctionality( obj,  deploymentProcessSumary);
        
        //-------------------------------------find a deployment controller------------------------------------
        
        //Initialize findAdeployment controller
        FindADeploymentController findAdeployment = new FindADeploymentController();
        
        //Set the property of findAdeployment component properties
        findAdeployment.deploymentTrackRef = obj.deploymentTrack;
        findAdeployment.deploymentTrackForSearch.Start_date__c = Date.today();
        findAdeployment.deploymentTrackForSearch.End_date__c = Date.today()+1;
        findAdeployment.deploymentTrackForSearch.Source_Org__c = 'Connection 1';
        findAdeployment.deploymentTrackForSearch.Target_Org__c = 'Connection 2';
        findAdeployment.deploymentTrackForSearch.Deployed_By__c = UserInfo.getUserId();
        findAdeployment.deploymentTrackForSearch.Deployment_Process__c = 'Validation';
        findAdeployment.deploymentTrackForSearch.Deployment_Change_Request__c = modification.Id;
        findAdeployment.deploymentTrackForSearch.Deployment_Release_Project__c = release.Id;
        
        //Search Deployment For particular Filter criteria
        findAdeployment.searchDeployments();
        
        //Check if start date is greater than today
        findAdeployment.deploymentTrackForSearch.Start_date__c = Date.today() +1;
        
        //Search Deployment For particular Filter criteria
        findAdeployment.searchDeployments();
        
        //Check if start date is greater than end date
        findAdeployment.deploymentTrackForSearch.End_date__c = Date.today();
        
        //Search Deployment For particular Filter criteria
        findAdeployment.searchDeployments();
        
        //clear the search 
        findAdeployment.clearSearch();
        
        //Get all the properties of getter type
        List<SelectOption> deploymentCategories = findAdeployment.deploymentCategories;
        List<Deployment_Track__c> searchedDeploymentList = findAdeployment.searchedDeploymentList;
        List<SelectOption> getSelectOptionListByField = DeploymentHelper.getSelectOptionListByField('Deployment_Track__c', 'Name');
        Boolean hasPrevious = findAdeployment.hasPrevious;
        Boolean hasNext = findAdeployment.hasNext;
        Integer pageNumber = findAdeployment.pageNumber;
        List<Integer> pagingNumbers = findAdeployment.pagingNumbers;
        findAdeployment.setSelectedStep();
        findAdeployment.next();
        findAdeployment.previous();  
        
       
        
    }  


    
     /*  @description    :  Meathod to test TestRunFunctionality of OneClick deployment 
    *
    *  @args           	:  DeploymentWizardController , IS_System_Modification__c
    *
    *  @return         	:   void
    *
    **/
    public static void test_TestRunFunctionality(DeploymentWizardController obj, IS_System_Modification__c modification){
        
         //Asserrt for app state
        System.assertEquals('Test Run',  obj.appProperties.appState);
		
        //Assert to check deployment track object update
        System.assertEquals('Test Run',obj.deploymentTrack.Deployment_Process__c);
        
         //Initialize test run controller object
        TestRunController objTest = new TestRunController();
        
        //Initialize test run controller page properties
        objTest.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id); 
        objTest.appPropertiesRef = obj.appProperties ;
        
        //Initialize deployment summary
        Deployment_Process_Summary__c processSummary1 = new Deployment_Process_Summary__c();
        
        //Get the Record type for test run
        String RecordTypeId = [SELECT Id, Name, DeveloperName from RecordType WHERE sobjectType = 'Deployment_Process_Summary__c' AND DeveloperName = 'Test_Run_Summary'].Id;
        
        //Execute check for if test run is required
        Boolean check = objTest.isTestRunRequired;
        
        //Execute tests
        objTest.runTest();
                   
        //Get the id for test run
        Id testSummary = objTest.deploymentTrackRef.Recent_Test_Run__c;
        
        List<Deployment_Process_Summary__c> recentTestRun =[Select ID, Status__c From Deployment_Process_Summary__c where Id =:testSummary ];
      
        if(recentTestRun.size() > 0)
        	System.assert(true);
        else
            System.assert(false);
        
        System.assertEquals('Started',recentTestRun[0].Status__c );
        
        //Initilize Deployment_Process_Summary__c sobject instance
        Deployment_Process_Summary__c testRunprocessSummary  = new Deployment_Process_Summary__c();
        
        //Assing values to Deployment_Process_Summary__c
        testRunprocessSummary.id = testSummary;
        testRunprocessSummary.Status__c = 'In Progress';
        
        //Update status to in progress
        update testRunprocessSummary;
        
        //List to hold test results data
        List<Test_Result__c> testData = new List<Test_Result__c>();
        //Instance of tesr result sobject
        Test_Result__c testResultData = new Test_Result__c();
        
        //Record data main class
        testResultData.Name = 'AccountTriggerHelper';
        testResultData.Main_Class_Name__c = 'AccountTriggerHelper';
        testResultData.Main_Class_Id__c = '01pC0000000t4OUIAY';
        testResultData.Coverage__c	= 90;
        testResultData.Total_Line__c = 585;
        testResultData.Class_Type__c = 'Main Class';
        testResultData.Total_Number_of_Covered_Line__c = 524;
        testResultData.IS_System_Modification__c = modification.id;
        testData.add(testResultData); 
        
        //Test class record data
        testResultData = new Test_Result__c();
        testResultData.Name = 'Test_SiteProfileTriggerHelper';
        testResultData.Test_Class_Name__c = 'Test_SiteProfileTriggerHelper';
        testResultData.Class_Type__c = 'Test Class';
        testResultData.IS_System_Modification__c = modification.id;
        testResultData.Test_Class_Id__c = '01pC0000000Vh2qIAC';
        testResultData.Result__c = 'Success';
        testResultData.Method_Name__c = 'testNewSiteProfile_Status_R3_to_L2';
        testData.add(testResultData); 
        
        //Insert test records
        insert testData;
        
        //Insert junction record
        Test_Run_Status__c junction  = new Test_Run_Status__c();
        junction.Test_Summary__c = testSummary;
        junction.Test_Class__c = [Select Id from Test_Result__c where Name ='Test_SiteProfileTriggerHelper' Limit 1 ].Id;
        junction.Main_Class__c = [Select Id from Test_Result__c where Name ='AccountTriggerHelper' Limit 1 ].Id;
        insert junction;
        
        //Check if test results are complete
        objTest.checkTestRunStatus();
        
        //update test summary
        testRunprocessSummary.Status__c = 'Completed';
        update testRunprocessSummary;
        
        recentTestRun =[Select ID, Status__c From Deployment_Process_Summary__c where Id =:testSummary ];
        System.assertEquals('Completed',recentTestRun[0].Status__c );
        
        
        //Check if test results are complete
        objTest.checkTestRunStatus();
        
        //Add test results to list
        List<Test_Result__c> results = objTest.testResults;
        obj.appProperties.forceMove = 'Want to move to package retrieval';
        
        obj.appProperties.appState = 'Env Setup';
        //update test result data
        DeploymentWizardHelper.updatedTestRunDetails(objTest.deploymentTrackRef, obj.appProperties);
          System.assert( objTest.testRunStatus.size() > 0);
        
        objTest.deploymentTrackRef.Recent_Test_Run__c  = null;
         obj.appProperties.appState = 'Env Setup';
        //update test result data
        DeploymentWizardHelper.updatedTestRunDetails(objTest.deploymentTrackRef, obj.appProperties);
        
        System.assert( objTest.testRunStatus.size() > 0);
        System.debug('objTest.testRunStatus'+ objTest.testRunStatus);
        
        //Move to next step
        obj.moveNext();
        
        
    }
    
    /*  @description    :  Meathod to test PackageRetrival of OneClick deployment 
    *
    *  @args           	:  DeploymentWizardController , IS_System_Modification__c
    *
    *  @return         	:   void
    *
    **/
    public static void testPackageRetrival(DeploymentWizardController obj , Deployment_Process_Summary__c packageRetrievalprocessSummary ){
          
        //Asserrt for app state
        System.assertEquals('Package Retrieval',  obj.appProperties.appState);
        
         //Initialize packageretrival controller class 
        PackageRetrievalController objPackage = new PackageRetrievalController();
        
        //Initialize test run controller page properties
        objPackage.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id);
        objPackage.appPropertiesRef = obj.appProperties ;
        
        //Retrieve package
        objPackage.retrievePackage();
        
        //check if retrive is complete
        objPackage.checkRetrievalStatus();
        
        List<Deployment_Process_Summary__c> recentPackageRetrival =[Select ID, Status__c From Deployment_Process_Summary__c where Id =:objPackage.deploymentTrackRef.Recent_Package_Retrieval__c ];
      
        if(recentPackageRetrival.size() > 0)
        	System.assert(true);
        else
            System.assert(false);
        
        //Update test summary record
        packageRetrievalprocessSummary.id = objPackage.deploymentTrackRef.Recent_Package_Retrieval__c;
        packageRetrievalprocessSummary.Status__c = 'Completed';
        update packageRetrievalprocessSummary;
        
        //check if retrive is complete
        objPackage.checkRetrievalStatus();
        
        //Initialize the package retrieval object
        List<Package_Retrieval_Result__c> retrievalData = objPackage.retrievalResults;
        
        //Set the recent package retrieval id in deployment track object
        obj.deploymentTrack.Recent_Package_Retrieval__c = objPackage.deploymentTrackRef.Recent_Package_Retrieval__c;
        
        obj.appProperties.forceMove = 'Want to move to crosscheck';
        
        //For code coverage
        obj.appProperties.appState = 'Package Retrieval';
        obj.deploymentTrack.Recent_Package_Retrieval__c  = null;
        //update Retrieval result data
        DeploymentWizardHelper.updatedPackageRetrievalDetails(objPackage.deploymentTrackRef, obj.appProperties);
        
        obj.appProperties.appState = 'Package Retrieval';
        //Set the recent package retrieval id in deployment track object
        obj.deploymentTrack.Recent_Package_Retrieval__c = objPackage.deploymentTrackRef.Recent_Package_Retrieval__c;
        
        //Move to next step
        obj.moveNext();
        

    }
	 /*  @description    :  Meathod to test CrossCheckFunctionality of OneClick deployment 
    *
    *  @args           	 :  DeploymentWizardController , Deployment_Process_Summary__c, Attachment
    *
    *  @return         	:   void
    *
    **/    
    public static void testCrossCheckFunctionality(DeploymentWizardController obj,  Deployment_Process_Summary__c packageRetrievalprocessSummary ,Attachment attachment){
        
        
         //Asserrt for app state
        System.assertEquals('Crosscheck',  obj.appProperties.appState);
         //Initialize the crosscheck controller
        CrosscheckController objCrossCheck = new CrosscheckController();
       
        //Initialize test run controller page properties
        objCrossCheck.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id);
        objCrossCheck.appPropertiesRef = obj.appProperties ;
        
        //Crosscheck the package that there is any overlapping exist or not
        objCrossCheck.doCrosscheck();
        
        //Assert to check results
        //System.assert(objCrossCheck.resultsWrapper.size() > 0);
        
         List<Deployment_Process_Summary__c> recentCrossCheck =[Select ID, Status__c From Deployment_Process_Summary__c where Id =:objCrossCheck.deploymentTrackRef.Recent_Crosscheck__c ];
      
        /*if(recentCrossCheck.size() > 0)
        	System.assert(true);
        else
            System.assert(false);*/
        
        //Update Crossceck summary record
        Deployment_Process_Summary__c crossCheckProcessSummary  = new Deployment_Process_Summary__c();
        crossCheckProcessSummary.id = objCrossCheck.deploymentTrackRef.Recent_Crosscheck__c;
        crossCheckProcessSummary.Status__c = 'Completed';
        update crossCheckProcessSummary;
        
        //For uploading the package 
        String zipFileName = 'RetrievalResult.zip';
        String zipContent = 'abc';

        attachment.Body = Blob.valueOf('abc');
        attachment.ContentType = 'application/zip';
        attachment.Name = String.valueOf('RetrievalResult.zip');
        attachment.ParentId = packageRetrievalprocessSummary.id; 
        //insert attachment;
        
        //Attach the attachment to the crosscheck property
        objCrossCheck.uploadPackage = attachment;
        
        //Upload the package
        objCrossCheck.uploadPackage();
        
        //If user want to download the attachment
        attachment = objCrossCheck.downloadAttachment;
        
        //Force move to the validation screen
        obj.appProperties.forceMove = 'Move to validation';
        
        //--------Improve code coverage
        
        //Update the crosscheck detail
        DeploymentWizardHelper.updatedCrosscheckDetails(objCrossCheck.deploymentTrackRef, obj.appProperties);
        
        //Get the off set 
        Double offset = objCrossCheck.offset;
        
        obj.appProperties.appState = 'Crosscheck';
        //If recent crosscheck id is null than update crosscheck detail
        objCrossCheck.deploymentTrackRef.Recent_Crosscheck__c = null;
        //update crosscheck detail
        DeploymentWizardHelper.updatedCrosscheckDetails(objCrossCheck.deploymentTrackRef, obj.appProperties);
         
       //--Restore state
        obj.appProperties.appState = 'Validation';
        //Move to next step
        obj.moveNext();
         obj.appProperties.appState = 'Validation';
        
        
        
    
    }
    /*  @description    :  Meathod to test ValidationFunctionality of OneClick deployment 
    *
    *  @args           	 :  DeploymentWizardController , Deployment_Process_Summary__c, Attachment
    *
    *  @return         	:   void
    *
    **/  
    public static void testValidationFunctionality(DeploymentWizardController obj, Attachment attachment , String reportURL ){
        
         System.assertEquals('Validation', obj.appProperties.appState);
        
        //Initialize the validation controller
        ValidationController validationControler = new ValidationController();
        
        System.debug('obj.deploymentTrack.Id' + obj.deploymentTrack.Id);
        //Set the deployment track instance of deployment validation
        validationControler.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id);
        validationControler.appPropertiesRef = obj.appProperties ;
        validationControler.isDefaultRun = true;
        
        //Update Crossceck summary record
        System.debug('validationControler.deploymentTrackRef.Recent_Validation__c;'+validationControler.deploymentTrackRef.Recent_Validation__c);
        Deployment_Process_Summary__c validationProcessSummary  = new Deployment_Process_Summary__c();
        validationProcessSummary.id = validationControler.deploymentTrackRef.Recent_Validation__c;
        validationProcessSummary.Status__c = 'Completed';
        validationProcessSummary.Validation_Status__c = 'Pass';
        update validationProcessSummary;
    
        //partial Validation
        validationControler.doPartialValidate();
        
        //Full validation
        validationControler.fullValidate();
       
        //Change the status of validation
        validationControler.processSummary.Status__c = 'Completed';
        validationControler.processSummary.Validation_Status__c = 'Pass';
        
        //Check the validation status
        validationControler.checkValidationStatus();
        
        //Get the target org backup
        validationControler.runTargetBackup();
        
        //Change the target org backup status to complete
        validationControler.processSummary.Target_Backup_Status__c = 'Completed';
        
        //Check the target backup status
        validationControler.checkTargetBackupStatus();
      
        //Assert in download attachment
        attachment = null;
        attachment = validationControler.downloadAttachment;
        System.assert(attachment != null);
        
        //Assert in targetBackup attachment
        attachment = null;
        attachment = validationControler.targetBackup;
        System.assert(attachment != null);
        
        //Assert in uploadPackage attachment
        attachment = null;
        attachment = validationControler.uploadPackage;
        System.assert(attachment != null);
        
        //Check that there is prevalidation step is available or not
        Boolean isPrevalidationStep = validationControler.isPreValidationStep;
        
        reportURL = null;
        //Get the report url
         reportURL = validationControler.reportURL;
        System.assert(reportURL != null);
        
        //Fetch the validion result if there is no validate error than it will be null
        List<Package_Validation_Deployment_Result__c> validationResults = validationControler.validationResults;
      
        //populate the validation result
        ValidationHelper.populateValidationResults(validationControler.processSummary.Id);
        
        //Initialize validation controller process summary
        validationControler.processSummary = new Deployment_Process_Summary__c();
        
        //Set the package detail
        validationControler.uploadPackage.Name = 'abc';
        validationControler.uploadPackage.Body = Blob.valueOf('sfs');
        
        //Upload the package
        validationControler.uploadPackage();
        
        obj.moveNext();
        
    }
    
    /*  @description    :  Meathod to test testDeploymentFuntionality of OneClick deployment 
    *
    *  @args           	 :  DeploymentWizardController , Deployment_Process_Summary__c, Attachment,String
    *
    *  @return         	:   void
    *
    **/  
    public static void testDeploymentFuntionality(DeploymentWizardController obj,  Deployment_Process_Summary__c deploymentProcessSumary , Attachment attachment , String reportURL){
        
        //Assert to check app state
        System.assertEquals('Deployment',  obj.appProperties.appState);
        
        //Initialize deployment conroller
        PackageDeploymentController deploymentControler = new PackageDeploymentController();
        
        //set the deployment track value
        deploymentControler.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id);
        deploymentControler.appPropertiesRef = obj.appProperties;
        
        //Get the value in the getter type properties
        deploymentProcessSumary = deploymentControler.processSummary;
       
        //Get the deployment result if there is no deployment error than it will be null
        List<Package_Validation_Deployment_Result__c> deploymentResults = deploymentControler.deploymentResults;
        
        //Check that there is prevalidation step or not
        Boolean isPreDeploymentStep = deploymentControler.isPreDeploymentStep;
        
        //Check that deployment is available for quick deployment or not
        Boolean isForQuickDeploy = deploymentControler.isForQuickDeploy;

        reportURL = null;
        //Get the report url
        reportURL = deploymentControler.reportURL;
        System.assert(reportURL != null);
        
        //If package is available for quick deployment
        deploymentControler.doQuickDeployment();
        
        //If package is not available for quick deploy
        deploymentControler.doFullDeployment();
        
        //Check the deployment status
        deploymentControler.checkDeploymentStatus();
        
        //Check that there is post deployment step available or not
        Boolean isPostDeploymentStep = deploymentControler.isPostDeploymentStep;
        System.assert(isPostDeploymentStep == false);
        
        //Get report url of after deployment
        String reportURLPostDeployment = deploymentControler.reportURLPostDeployment;
        
        //Get the deployment result if there is no error than it will be null
        List<Package_Validation_Deployment_Result__c> result = PackageDeploymentHelper.populateDeploymentResults(deploymentProcessSumary.Id);

        //Get the target backup 
        attachment = null;
        attachment = deploymentControler.targetBackup;
        System.assert(attachment != null);
        
        //Get the target backup and download it
        attachment = null;
        attachment = deploymentControler.downloadAttachment;
        System.assert(attachment != null);
    }
    
    /*  @description    :  Meathod to test testDeploymentSummaryFunctionality of OneClick deployment 
    *
    *  @args           	 :  DeploymentWizardController , Deployment_Process_Summary__c
    *
    *  @return         	:   void
    *
    **/  
    public static void testDeploymentSummaryFunctionality(DeploymentWizardController obj, Deployment_Process_Summary__c deploymentProcessSumary){
        
         //Initialize the deployment summary controller
        DeploymentSummaryController deploymentSummary = new DeploymentSummaryController();
        deploymentSummary.deploymentTrackRef = DeploymentWizardHelper.populateDeploymentTrack(obj.deploymentTrack.Id);
        deploymentSummary.appPropertiesRef = obj.appProperties;
        
        //Update deployment record
        Deployment_Process_Summary__c deploymentProcessSummary  = new Deployment_Process_Summary__c();
        deploymentProcessSummary.id = deploymentSummary.deploymentTrackRef.Recent_Deployment__c;
        deploymentProcessSummary.Status__c = 'Completed';
        deploymentProcessSummary.Deployment_Status__c = 'Pass';
        update deploymentProcessSummary;
		
		
        //Fetch the test run summary detail
        Deployment_Process_Summary__c testRunSummary = deploymentSummary.testRunSummary;
        deploymentSummary.deploymentTrackRef.Recent_Test_Run__c = null;
        testRunSummary = deploymentSummary.testRunSummary;
        System.assert(testRunSummary != null);
        
        //Fetch the Package retrieval summary detail
        Deployment_Process_Summary__c packageRetrievalSummary = deploymentSummary.packageRetrievalSummary;
        deploymentSummary.deploymentTrackRef.Recent_Package_Retrieval__c = null;
        packageRetrievalSummary = deploymentSummary.packageRetrievalSummary;
         System.assert(packageRetrievalSummary != null);
        
        //Fetch the crosscheck summary detail
        Deployment_Process_Summary__c crosscheckSummary = deploymentSummary.crosscheckSummary;
        deploymentSummary.deploymentTrackRef.Recent_Crosscheck__c = null;
        crosscheckSummary = deploymentSummary.crosscheckSummary;
        System.assert(crosscheckSummary != null);
        
        //Fetch validation summary detail
        Deployment_Process_Summary__c validationSummary = deploymentSummary.validationSummary;
        deploymentSummary.deploymentTrackRef.Recent_Validation__c = null;
        validationSummary = deploymentSummary.validationSummary;
         System.assert(validationSummary != null);
        
        //Fetch deploymennt summary detail
        Deployment_Process_Summary__c deploymentSumary = deploymentSummary.deploymentSummary;
        deploymentSummary.deploymentTrackRef.Recent_Deployment__c = deploymentProcessSumary.Id;
        deploymentSumary = deploymentSummary.deploymentSummary;
        System.assert(deploymentSumary != null);
       
    }
    
   /*  @description    :  Meathod to test -ve case of validate connection class of OneClick deployment 
    *
    *  @args           	 : none
    *
    *  @return         	:   void
    *
    **/  
    static testMethod void testValidateConnectionNegativeCase(){
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        Test.stopTest();      
    }
    
    //Modified by 02/06/2020
    static testMethod void testupdatedTestRunDetails(){
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        obj.appProperties.forceMove = 'Want to move to package retrieval';
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        Test.stopTest();      
        
        system.assert(obj.deploymentTrack.Recent_Test_Run__c == null);
        system.assert(String.isNotBlank(obj.appProperties.forceMove));
        
        DeploymentWizardHelper.updatedTestRunDetails(obj.deploymentTrack, obj.appProperties ); 
    }
    
    //Modified by 02/06/2020
    static testMethod void testupdatedPackageRetrievalDetails(){
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.appProperties.forceMove = 'Want to move to package retrieval';
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        Test.stopTest();      
        
        system.assert(obj.deploymentTrack.Recent_Package_Retrieval__c == null);
        system.assert(String.isNotBlank(obj.appProperties.forceMove));
        
        DeploymentWizardHelper.updatedPackageRetrievalDetails(obj.deploymentTrack, obj.appProperties ); 
    }
    
    //Modified by 02/06/2020
    static testMethod void testupdatedDeploymentDetails(){
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        
        Deployment_Track__c dep = new Deployment_Track__c(Deployment_Type__c='Manual');
        insert dep;
        
        Test.stopTest(); 
        
        system.assert(dep != null);
        system.assert(obj.deploymentTrack != null);
        system.assert(obj.appProperties != null);
        
        DeploymentWizardHelper.getManualStepsData(dep);
        DeploymentWizardHelper.updatedDeploymentDetails(obj.deploymentTrack, obj.appProperties ); 
        
    }
    
    //Modified by 02/06/2020
    static testMethod void testpopulateApplicationProperties(){
        
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        
        //List to hold the CR
        List<SFDC_Change_Request__c> sfdcChangerequests = new List<SFDC_Change_Request__c>();
        
        sfdcChangerequests.add(new SFDC_Change_Request__c(Title__c = 'Demo Change Request', Status__c= '03-Approved',
                                                               Request_Description__c = 'demo',
                                                               Business_Justification__c = 'demo', Release__c = release.Id));
        util.bypassAllTriggers = true;
        insert sfdcChangerequests;
        
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        obj.deploymentTrack.Deployment_Change_Request__c = sfdcChangerequests[0].Id;
		obj.deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_ENV_SETUP;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        
        Deployment_Track__c dep = new Deployment_Track__c(Deployment_Type__c='Manual');
        insert dep;
        
        Test.stopTest();  
        
        system.assert(obj.deploymentTrack != null);
        system.assert(release != null);
        system.assert(sfdcChangerequests.size()>0);
        system.assert(obj.appProperties != null);
        
        
        DeploymentWizardHelper.populateApplicationProperties(obj.deploymentTrack, obj.appProperties ); 
        
    }
    
    
    //Modified by 02/06/2020
    static testMethod void testInsertProcessSummary(){
        
        Test.startTest();
        //Get release id
        SFDC_Release__c release = [ Select Id from SFDC_Release__c where Name = 'Overlapping Release1' Limit 1];
        
        //Get modification id
        IS_System_Modification__c modification = [Select Id from IS_System_Modification__c Limit 1];
        
        //Set mock heep class
        Test.setMock(HttpCalloutMock.class, new Test_ValidateConnectionMockNegativeCase());    
              
        //Initialize deployment wizard Controller
        DeploymentWizardController obj = new DeploymentWizardController();
        
        //From deployment wizard helper we can fetch connection Connection name if they exist like this connection not exist so it will return null;
        String connection = string.valueOf(DeploymentWizardHelper.getConnectionData('Connection abc'));
        
        //Set OneClick deploy default page (Env Setup) properties
        obj.appProperties.selectedSourceCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 1'));
        obj.appProperties.selectedTargetCon = String.valueOf(DeploymentWizardHelper.getConnectionData('Connection 2'));
        obj.appProperties.forceMove = 'Want to move to package retrieval';
        obj.deploymentTrack.Sandbox_Refresh_Date__c  = Date.today() - 2;
        obj.deploymentTrack.Deployment_Release_Project__c = release.Id;
        
        //for deploymentwizardbean coverage
        Connection__c con = obj.appProperties.sourceConnectionData;
        con = obj.appProperties.targetConnectionData;
        List<SelectOption>  dataList = obj.appProperties.deploymentProgressOptions;
        dataList = obj.appProperties.connections;
        String testBean = obj.appProperties.orgLoginEndPoint;

         System.assertEquals('Env Setup',  obj.appProperties.appState);
        
        //Move wizard to next step( validate env settings for -ve case)
        obj.moveNext();
        
        //If any error occure on page that will store in this property
        String error = obj.ConnectionError;
        
        Deployment_Process_Summary__c packageRetrievalprocessSummary = new Deployment_Process_Summary__c();
        
        List<RecordType> rcrdt = [SELECT Id FROM RecordType WHERE sObjectType = 'Deployment_Process_Summary__c' LIMIT 1];
        Test.stopTest();      
        
        system.assert(rcrdt.size() == 1);
        system.assert(obj.deploymentTrack.Recent_Validation__c == null);
        system.assert(packageRetrievalprocessSummary != null);
        system.assert(String.isNotBlank(obj.appProperties.forceMove));
        
        DeploymentWizardHelper.InsertProcessSummary(obj.deploymentTrack, packageRetrievalprocessSummary, obj.appProperties, rcrdt[0].Id );
        
        
        DeploymentWizardHelper.updatedValidationDetails(obj.deploymentTrack, obj.appProperties ); 
        
    }
    

    
}