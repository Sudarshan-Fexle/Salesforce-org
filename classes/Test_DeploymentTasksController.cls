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
 **/
   /**
    *   Purpose         :     Test class for Deployment Tasks Controller
    *            
    *   Create By       :     Divya Bharadwaj(simplyforce)
    * 
    *   Created Date    :     08/31/2017
    *
    *   Revision Log    :     V_1.0 - Created
    *		      	:     V_1.1 - Modified By Saurabh Kumar - 09/16/2017
    *		      	:     V_1.2 - Modified By Dipesh Gupta  - 09/28/2017 - CR-20170907-11182 - added a new flag to bypass the dlrs while testing
    *		      	:     V_1.3 - Modified By Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
    *		      	:     V_1.4 - Modified By Nikita Kumari - 07/14/2021 - CR-20211005-15489 - To Increase code coverage.
    *
    *   Coverage        :     92%
    **/ 
@isTest
private class Test_DeploymentTasksController {
    
   /**
    * @Description  : This method used to test functionality
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    *               : V_1.1 - Modified by Nikita Kumari - 07/14/2021 - To Increase the Code coverage
    **/
    
    @testSetup static void setup() {
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
        
        //Insert release record
        List<SFDC_Release__c> releaseList = new List<SFDC_Release__c> ();
        
        releaseList.add(new SFDC_Release__c(Name = 'Release 1.0',
                                            Environment_Manager__c = usr.Id,
                                            Status__c = 'Scheduled - Planned',
                                            Release_Manager__c = usr.Id,
                                            Dev_Sandbox__c = devEnv[0].Id,
                                            QA_Sandbox__c = devEnv2[1].Id,
                                            UAT_Sandbox__c = devEnv2[1].Id,
                                            Release_level__c = 'L2' /*, Target_Release_Date__c = Date.today() */));
        releaseList.add(new SFDC_Release__c (Name = 'Release 2.0',
                                             Environment_Manager__c = usr.Id,
                                             Status__c = 'Scheduled - Planned',
                                             Release_Manager__c = usr.Id,
                                             Dev_Sandbox__c = devEnv[0].Id,
                                             QA_Sandbox__c = devEnv2[1].Id,
                                             UAT_Sandbox__c = devEnv2[1].Id,
                                             Release_level__c = 'L2'/*, Target_Release_Date__c = Date.today() */));
        // Modified - Nikita Kumari - 07/14/2021 (Name - Release 1.0  -> Release 3.0)
        releaseList.add(new SFDC_Release__c(Name = 'Release 3.0',
                                            Environment_Manager__c = usr.Id,
                                            Status__c = 'Scheduled - Planned',
                                            Release_Manager__c = usr.Id,
                                            Dev_Sandbox__c = devEnv[0].Id,
                                            QA_Sandbox__c = devEnv2[1].Id,
                                            UAT_Sandbox__c = devEnv2[1].Id,
                                            Release_level__c = 'L2' , 
                                            Target_Release_Date__c = Date.today().AddDays(1) ));
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        //
        insert releaseList; 		
        
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
        
        Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');
        
        //Insert a test contact
        Contact contact = new Contact(LastName = 'TestContact', Email = 'test@test.com', Employee_User_Record__c = UserInfo.getUserId(),
                                      RecordTypeId = employeeRTId);
        insert contact;
        
        //Insert test 
        IS_System__c testISRecord = new IS_System__c (Name = 'IS Record');
        insert testISRecord;
        
        //Insert Change Request record
        List<SFDC_Change_Request__c> changeRequestList = new List<SFDC_Change_Request__c> ();
        
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                                         Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                                         Business_Justification__c = 'Test', SFDC_Release__c = releaseList[0].Id ));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.2', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                                         Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                                         Business_Justification__c = 'Test', SFDC_Release__c = releaseList[0].Id));
        changeRequestList.add(new SFDC_Change_Request__c (Title__c = 'Test CR 1.3', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                                          Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                                          Business_Justification__c = 'Test', SFDC_Release__c = releaseList[1].Id));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.4', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                                         Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                                         Business_Justification__c = 'Test', SFDC_Release__c = releaseList[1].Id));
        //Added by Nikita Kumari - 07/14/2021
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.5', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                                         Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                                         Business_Justification__c = 'Test', SFDC_Release__c = releaseList[2].Id));
        
        
        //insert 
        insert changeRequestList;
        
        //Insert SFDC Modifications
        List<IS_System_Modification__c> modifications = new List<IS_System_Modification__c>();
        
        //add modification record in list
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[1].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        
        //V_1.1 - Modified by Saurabh Kumar - 09/16/2017
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[1].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[2].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test2',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[4].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test4',
                                                         IS_System_Component__c = listIsSysComp[5].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test2',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[4].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test4',
                                                         IS_System_Component__c = listIsSysComp[5].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test5',
                                                         IS_System_Component__c = listIsSysComp[6].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test6',
                                                         IS_System_Component__c = listIsSysComp[6].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test7',
                                                         IS_System_Component__c = listIsSysComp[7].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test8',
                                                         IS_System_Component__c = listIsSysComp[7].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test9',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[8].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = false
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[0].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[8].Id,
                                                         SFDC_Change_Request__c = changeRequestList[0].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = false
                                                        ));
        
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[1].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        
        //V_1.1 - Modified by Saurabh Kumar - 09/16/2017
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[1].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test1',
                                                         IS_System_Component__c = listIsSysComp[2].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test2',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[4].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test4',
                                                         IS_System_Component__c = listIsSysComp[5].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test2',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test3',
                                                         IS_System_Component__c = listIsSysComp[4].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test4',
                                                         IS_System_Component__c = listIsSysComp[5].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test5',
                                                         IS_System_Component__c = listIsSysComp[6].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test6',
                                                         IS_System_Component__c = listIsSysComp[6].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test7',
                                                         IS_System_Component__c = listIsSysComp[7].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test8',
                                                         IS_System_Component__c = listIsSysComp[7].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test9',
                                                         IS_System_Component__c = listIsSysComp[3].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[8].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = false
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[1].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[8].Id,
                                                         SFDC_Change_Request__c = changeRequestList[1].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = false
                                                        ));
        //Added by Nikita Kumari - 07/14/2021 - Start
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[4].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[0].Id,
                                                         SFDC_Change_Request__c = changeRequestList[4].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        modifications.add(new IS_System_Modification__c (Change_Request__c = changeRequestList[4].Id, Manual_Step__c = true, Label__c = 'Test10',
                                                         IS_System_Component__c = listIsSysComp[2].Id,
                                                         SFDC_Change_Request__c = changeRequestList[4].Id,
                                                         Include_in_Change_Set__c = true,
                                                         Potential_Overlapping__c = true
                                                        ));
        //Added by Nikita Kumari - 07/14/2021 - end
        //Insert
        insert modifications;
        
        List<IS_System_Modification__c> mods = [Select Id, IS_System_Component__r.Object_API_Name__c From IS_System_Modification__c];
        
        //Get the "Issue" record type Id of "CR Action Item" Object 
        List<RecordType> recordTypeIdCRA = [Select Id, Name From RecordType where SobjectType =: 'CR_Action_Item__c' AND DeveloperName =: 'Issue' limit 1];
        
        System.assert(recordTypeIdCRA.size() > 0);
        
        //Insert a Issue record
        CR_Action_Item__c issueCRA = new CR_Action_Item__c(Name = 'TestCRAIssue', Action_Item_Status__c = 'New', Change_Request__c = changeRequestList[0].id,
                                                           Issue_Date__c = system.today(), Classification__c = 'Bug', Priority__c = '3-Medium', 
                                                           Type__c = 'QA', RecordTypeId = recordTypeIdCRA[0].Id,
                                                           IS_System_Modification__c = modifications[0].Id);
        //Enable All the triggers
        Util.BypassAllTriggers = true;
        
        //Insert
        insert issueCRA;
        
        //Added by Nikita Kumari - 07/14/2021
        CR_Action_Item__c issueCRA1 = new CR_Action_Item__c(Name = 'TestCRAIssue1', Action_Item_Status__c = 'New', Change_Request__c = changeRequestList[0].id,
                                                            Issue_Date__c = system.today(), Classification__c = 'Bug', Priority__c = '3-Medium', 
                                                            Type__c = 'QA', RecordTypeId = recordTypeIdCRA[0].Id,
                                                            IS_System_Modification__c = modifications[43].Id); 
        
        //Enable All the triggers
        Util.BypassAllTriggers = true;
        
        //Insert
        insert issueCRA1;
        
        //System Administratot User
        User sysAdmin = [SELECT Name, Id, Email FROM User 
                         WHERE Profile.Name = 'System Administrator' AND IsActive = true  LIMIT 1];
        
        //Add record to list
        Deployment_Wizard_Access_Control__c dWizard = new Deployment_Wizard_Access_Control__c(Is_Deployment_Wizard_Accessible__c = true, Name = 'test',
                                                                                              SetupOwnerId = sysAdmin.Id);
        
        //Insert 
        insert dWizard;
        
        //Assert
        System.assert(dWizard != null);
        
    }
    
    static testmethod void testMyUnitTest() {
        Test.startTest();
        
        User sysAdmin = [SELECT Name, Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true  LIMIT 1];
        //List to hold status 
        List<String> excludeStatuses = new List<String>();
        
        //Add record to list
        excludeStatuses.add('07-In Dev QA');
        
        List<SFDC_Change_Request__c> changeRequestList = [Select Id,Title__c, IS_System__c , Priority__c, Status__c , Users_Affected__c ,
                                                          Requested_By2__c, Business_Operations_Contact2__c , Request_Description__c, 
                                                          Business_Justification__c, SFDC_Release__c From SFDC_Change_Request__c];
        
        List<SFDC_Release__c> releaseList = [Select Id,Name ,Environment_Manager__c ,  Status__c , Release_Manager__c,
                                             Dev_Sandbox__c, QA_Sandbox__c , UAT_Sandbox__c , Release_level__c,Target_Release_Date__c From SFDC_Release__c];
        
        //Modified by Nikita Kumari - 07/14/2021 - Added WHERE Clause in QUery									
        //Cr action item record list
        List<CR_Action_Item__c> issueCRA = [Select Id,Name, Action_Item_Status__c, Change_Request__c,Issue_Date__c , Classification__c , Priority__c , 
                                            Type__c , RecordTypeId,IS_System_Modification__c From CR_Action_Item__c]; 
        
        
        //modification record list
        List<IS_System_Modification__c> modifications = [ Select Id,Change_Request__c , Manual_Step__c, Label__c ,IS_System_Component__c,
                                                         SFDC_Change_Request__c ,Include_in_Change_Set__c,Potential_Overlapping__c,Duplicate_Mod_on_CR__c From IS_System_Modification__c ];
        
        List<IS_System_Modification__c> mods = [Select Id,Duplicate_Mod_on_CR__c ,IS_System_Component__r.Object_API_Name__c From IS_System_Modification__c];
        
        //List to hold StatusesMultiSelect
        List<String> statusList = new List<String>();
        
        //Add record to list
        statusList.add('02-Sponsored');
        statusList.add('04-Estimated'); 
        
        //Controller Object
        DeploymentTasksController dTaskObj1 =  new DeploymentTasksController();
        dTaskObj1.crosscheckAndDisplay();
                
        //Login as system Admin
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            system.assert(dTaskObj.sfdcMod != null); 
            system.assert(dTaskObj.crActionItem != null);	
            
            //Added by - Nikita Kumari - 07/08/2021 - to increase code coverage - Start
            
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = null;
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = null;
            dTaskObj.sfdcMod = null;	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = null;
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = null;
            dTaskObj.sfdcMod = null;	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = null;
            dTaskObj.sfdcMod = null;	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[2];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            //Added by - Nikita Kumari - 07/08/2021 - to increase code coverage - end   
        }
        
        //Login as system Admin 
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.selectedCrosscheckCategory = 'individualCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.release = releaseList[0];
            dTaskObj.sfdcMod = modifications[0];
            dTaskObj.sandboxName = 'test';	
            dTaskObj.getCRStatus();
            dTaskObj.getAllCRStatus();
            ModHelper mod = new ModHelper(null, null, null, null, null, null, null, null, null, null, null, null, null);
            mod.attachFile(changeRequestList[0].Id, 'Overlapping Text', false);
            mod.attachFile(changeRequestList[0].Id, 'Overlapping Text', true);
            mod.attachFile(changeRequestList[0].Id, null, false);
            mod.attachFile(null, 'Overlapping Text', false);
            mod.buildURL(changeRequestList[0].Id, 'CR-10001-67892');
            mod.getListOfModifications(true, true);
            mod.getListOfModifications(false, false);
            
            mod = new ModHelper(System.today().addDays(-30), changeRequestList[0], null, null, changeRequestList[0].Id, 'Test',  
                                'null', 'null', 'null', true, false, true, 'null');
            
            mod.overlappingModMap.put(mods[0].IS_System_Component__r.Object_API_Name__c, new ModWrapper(mods[1]));
            mod.identifyOverlappingMods(mods, false);
            mod.emailOverlappingModsListToUsers(false, changeRequestList[0].Id);
            
            dTaskObj.sfdcMod.SFDC_Change_Request__c = changeRequestList[0].Id;
            dTaskObj.crosscheckAndDisplay();
            dTaskObj.crosscheckAndAttach();
            dTaskObj.crosscheckAndEmail();
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.excludeCRNamesForPackage = 'Release 2.0';
            dTaskObj.excludeCRStatus = statusList;
            dTaskObj.packageAndDisplay();
            dTaskObj.packageAndEmail();
            
            system.assertEquals('#CrosscheckBlock',dTaskObj.selectedTab); 
            system.assertEquals('Release 2.0',dTaskObj.excludeCRNamesForPackage);
        }
        
        //Login as system admin
        system.runAs(sysAdmin) {        
            
            //Place Id of CR
            ApexPages.currentPage().getParameters().put('recordId', changeRequestList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj2 = new DeploymentTasksController();
            dTaskObj2.release = releaseList[0];
            dTaskObj2.sandboxName = 'test';
            dTaskObj2.getCRStatus();
            dTaskObj2.getAllCRStatus();
            dTaskObj2.crosscheckAndDisplay();
            dTaskObj2.crosscheckAndAttach();
            dTaskObj2.crosscheckAndEmail();
            dTaskObj2.packageAndDisplay();
            dTaskObj2.packageAndEmail(); 
        }
        
        //Login as system admin
        system.runAs(sysAdmin) {        
            
            //Place Id of Modification
            ApexPages.currentPage().getParameters().put('recordId', modifications[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj3 = new DeploymentTasksController();
            dTaskObj3.release = releaseList[0];
            dTaskObj3.getCRStatus();
            dTaskObj3.getAllCRStatus();
            dTaskObj3.sandboxName = 'test';
            dTaskObj3.crosscheckAndDisplay();
            dTaskObj3.crosscheckAndAttach();
            dTaskObj3.crosscheckAndEmail();
            dTaskObj3.sfdcModForPackage.Duplicate_Mod_on_CR__c = true;
            dTaskObj3.packageAndDisplay();
            dTaskObj3.packageAndEmail();			
            
        }
        
        //Login as system asmin
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.releasesForCrosscheck = 'Release 2.0';
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[0];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
        } 
        
        //Login as system admin		
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.release = releaseList[0];
            dTaskObj.sfdcMod = modifications[0];
            dTaskObj.releasesForCrosscheck = 'Release 2.0';			
            dTaskObj.changeRequestsForCrosscheck = changeRequestList[1].Id;
            dTaskObj.sfdcModsForCrosscheck = modifications[1].Id;
            dTaskObj.sandboxName = 'test';	
            dTaskObj.changeRequestForAttachment = changeRequestList[0];
            dTaskObj.getCRStatus();
            dTaskObj.getAllCRStatus();
            dTaskObj.crosscheckAndAttach();
            dTaskObj.sfdcModForAttachment = modifications[0];
            dTaskObj.crosscheckAndAttach();
            dTaskObj.crActionItemForAttachment = issueCRA[0];
            dTaskObj.crosscheckAndAttach();
            dTaskObj.selectedPackageCategory = 'individualPackage';
            dTaskObj.changeRequestForPackage = changeRequestList[0];
            dTaskObj.packageAndDisplay();
            dTaskObj.selectedPackageCategory = 'individualPackage';
            dTaskObj.changeRequestForPackage = null;
            dTaskObj.sfdcModForPackage = modifications[0];
            dTaskObj.excludeCRNamesForPackage = 'Release 2.0' ;
            
            List<IS_System_Modification__c> isSystemMod = [Select Id, Name, Change_Request__c, Manual_Step__c, IS_System_Component__c, SFDC_Change_Request__c,Duplicate_Mod_on_CR__c 
                                                           From IS_System_Modification__c];
            
            dTaskObj.excludeModNamesForPackage = isSystemMod[0].Name;
            dTaskObj.excludeCRStatusMultiSelect = excludeStatuses  ;
            dTaskObj.packageAndDisplay(); 
            dTaskObj.packageAndEmail();
            dTaskObj.packageAndAttach();
            dTaskObj.selectedPackageCategory = 'groupPackage';
            dTaskObj.releasesForPackage = 'Release 2.0';
            dTaskObj.changeRequestsForPackage = 'Test CR 1.1';
            dTaskObj.packageAndDisplay(); 
            dTaskObj.changeRequestForAttachmentOfPackage = changeRequestList[0];
            dTaskObj.packageAndAttach();
            dTaskObj.sfdcModForAttachmentOfPackage = modifications[0];
            dTaskObj.packageAndAttach();
            dTaskObj.crActionItemForAttachmentOfPackage = issueCRA[0];
            dTaskObj.packageAndAttach();
        }
        
        //Login as system admin
        system.runAs(sysAdmin) {        
            
            //Place Id of CR
            ApexPages.currentPage().getParameters().put('recordId', changeRequestList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj4 = new DeploymentTasksController();
            dTaskObj4.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj4.release = releaseList[0];
            dTaskObj4.releasesForCrosscheck = 'Release 2.0';
            dTaskObj4.sandboxName = 'test';
            dTaskObj4.getCRStatus();
            dTaskObj4.getAllCRStatus();
            dTaskObj4.crosscheckAndDisplay();
            dTaskObj4.crosscheckAndAttach();
            dTaskObj4.crosscheckAndEmail();
            dTaskObj4.packageAndDisplay();
            dTaskObj4.emailAddressForPackage = 'test@advisory.com' ;
            dTaskObj4.packageAndEmail();			
        }
        
        //Login as system admin
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.releasesForCrosscheck = 'Release 2.0';
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[0];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[0];
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();				
            dTaskObj.emailAddressForCrosscheck = 'test@gm.com';
            dTaskObj.release = releaseList[0];
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
        }
        
        //Login as system admin
        system.runAs(sysAdmin) {        
            
            //Place Id of CR
            ApexPages.currentPage().getParameters().put('recordId', changeRequestList[0].Id);
            
            List<IS_System_Modification__c> mod = [select Id, Name, Change_Request__c, Change_Request__r.Name, IS_System_Component__r.Name From IS_System_Modification__c 
                                                   Where Label__c = 'Test3' Limit 1];
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj4 = new DeploymentTasksController();
            dTaskObj4.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj4.release = releaseList[0];
            dTaskObj4.releasesForCrosscheck = 'Release 2.0';
            dTaskObj4.sandboxName = 'test';
            dTaskObj4.sfdcModsForCrosscheck = mod[0].Name;
            dTaskObj4.changeRequestsForCrosscheck = mod[0].Change_Request__r.Name;
            dTaskObj4.crosscheckAndEmail();
            dTaskObj4.getCRStatus();
            dTaskObj4.getAllCRStatus();
            dTaskObj4.crosscheckAndDisplay();
            dTaskObj4.crosscheckAndAttach();
            
        }
        
        Test.stopTest();
        //Util.ByPassDLRSForTest = false;
        
    }
    
    //Added By Nikita Kumari - 07/14/2021	
    static testmethod void testMyUnitTest1() {
        Test.startTest();
        
        User sysAdmin = [SELECT Name, Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true  LIMIT 1];
        //List to hold status 
        List<String> excludeStatuses = new List<String>();
        
        //Add record to list
        excludeStatuses.add('07-In Dev QA');
        
        List<SFDC_Change_Request__c> changeRequestList = [Select Id,Title__c, IS_System__c , Priority__c, Status__c , Users_Affected__c ,
                                                          Requested_By2__c, Business_Operations_Contact2__c , Request_Description__c, 
                                                          Business_Justification__c, SFDC_Release__c From SFDC_Change_Request__c Where Title__c = 'Test CR 1.5'];
        
        List<SFDC_Release__c> releaseList = [Select Id,Name ,Environment_Manager__c ,  Status__c , Release_Manager__c,
                                             Dev_Sandbox__c, QA_Sandbox__c , UAT_Sandbox__c , Release_level__c,Target_Release_Date__c From SFDC_Release__c Where Name = 'Release 3.0'];
        
        //Cr action item record list
        List<CR_Action_Item__c> issueCRA = [Select Id,Name, Action_Item_Status__c, Change_Request__c,Issue_Date__c , Classification__c , Priority__c , 
                                            Type__c , RecordTypeId,IS_System_Modification__c From CR_Action_Item__c]; 
        
        
        //modification record list
        List<IS_System_Modification__c> modifications = [Select Id,Change_Request__c , Manual_Step__c, Label__c ,IS_System_Component__c,
                                                         SFDC_Change_Request__c ,Include_in_Change_Set__c,Potential_Overlapping__c,Duplicate_Mod_on_CR__c From IS_System_Modification__c ];
        
        List<IS_System_Modification__c> mods = [Select Id,Duplicate_Mod_on_CR__c ,IS_System_Component__r.Object_API_Name__c From IS_System_Modification__c];
        
        //List to hold StatusesMultiSelect
        List<String> statusList = new List<String>();
        
        //Add record to list
        statusList.add('02-Sponsored');
        statusList.add('04-Estimated'); 
        
        //Login as system Admin
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[0];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.getAllCRStatus();
            dTaskObj.crosscheckAndAttach();
            
        }
        
        //Login as system asmin
        system.runAs(sysAdmin) {
            
            //Place Id of release
            ApexPages.currentPage().getParameters().put('recordId', releaseList[0].Id);
            
            //Instance of Cpntroller and its getter setter vairable
            DeploymentTasksController dTaskObj =  new DeploymentTasksController();
            dTaskObj.releasesForCrosscheck = 'Release 3.0';
            dTaskObj.selectedCrosscheckCategory = 'groupCrosscheck';
            dTaskObj.selectedTab = '#CrosscheckBlock';
            dTaskObj.crActionItem = issueCRA[1];
            dTaskObj.changeRequest = changeRequestList[0];
            dTaskObj.sfdcMod = modifications[0];	
            dTaskObj.getCRStatus();
            dTaskObj.emailAddressForCrosscheck = 'test@advisory.com';
            dTaskObj.release = releaseList[0];
            dTaskObj.sandboxName = 'Test1';
            dTaskObj.inProgressStatusesMultiSelect = statusList;
            dTaskObj.changeRequestForAttachment = changeRequestList[0];
            dTaskObj.getAllCRStatus();
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.changeRequestForAttachment = null;
            dTaskObj.sfdcModForAttachment = modifications[0];
            dTaskObj.CrosscheckAndEmail();
            
            dTaskObj.sfdcModForAttachment = null;
            dTaskObj.crActionItemForAttachment = issueCRA[1];
            dTaskObj.CrosscheckAndEmail();
            dTaskObj.crosscheckAndDisplay();
            
        } 
        Test.stopTest();
        Util.ByPassDLRSForTest = false;
    }
}