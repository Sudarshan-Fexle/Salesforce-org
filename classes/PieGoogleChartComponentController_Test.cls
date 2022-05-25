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
  *   Purpose         :     Test class for PieGoogleChartComponentController
  *            
  *   Create By       :     Divya Bharadwaj(simplyforce)
  * 
  *   Created Date    :     09/11/2017
  *
  *   Revision Log    :     V_1.0 - Created
  * 			    V_1.1 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
  *
  *   Coverage        :     85%
  **/ 
@isTest(seeAllData = false)
private class PieGoogleChartComponentController_Test {

  /**
    * @Description  : This method used to test functionality
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    **/
    static testmethod void testMyUnitTest() {
        
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
        
        releaseList.add(new SFDC_Release__c(Name = 'Release 1.0', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id, Release_level__c = 'L2'/*, Target_Release_Date__c = Date.today()*/));
        releaseList.add(new SFDC_Release__c (Name = 'Release 2.0', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id, Release_level__c = 'L2'/*, Target_Release_Date__c = Date.today()*/));
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
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
                                                      Object_API_Name__c = 'Account.Test1__C', Object_Type__c = 'Generic Object',
                                                      SOX_Object__c = true, Parent__c = parentObjComp.Id,
                                                      RecordTypeId = isSysCompRTypeId[0].Id
                                                     ));
        listIsSysComp.add(new Is_System_Component__c( Name = 'Test2', Object_Label__c = 'Test1', Custom__c = true,
                                                      Object_API_Name__c = '/TestReport__C', Object_Type__c = 'Dashboard/',
                                                      SOX_Object__c = true, Parent__c = parentObjComp.Id,
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
        
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.1', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved',
        						Users_Affected__c = 'All', Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test', Release__c = releaseList[0].Id ));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.2', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test', Release__c = releaseList[0].Id ));
        changeRequestList.add(new SFDC_Change_Request__c (Title__c = 'Test CR 1.3', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test', Release__c = releaseList[0].Id ));
        changeRequestList.add(new SFDC_Change_Request__c(Title__c = 'Test CR 1.4', IS_System__c = testISRecord.Id, Priority__c = 'A-Critical', Status__c = '03-Approved', Users_Affected__c = 'All',
                                Requested_By2__c = contact.Id, Business_Operations_Contact2__c = contact.Id , Request_Description__c = 'Testing', 
                                Business_Justification__c = 'Test', Release__c = releaseList[0].Id ));
         
        //insert 
        insert changeRequestList; 

		//Testing Start here
		Test.startTest();

		//Set current Page
		PageReference pageRef = Page.ChangeRequestDetailPageGoogleChartDashb;
        Test.setCurrentPage(pageRef);

		//Create a instance of Component
        PieGoogleChartComponentController pieGoogleChart = new PieGoogleChartComponentController();

		//Set object Id of Change request
		pieGoogleChart.sobjectId = changeRequestList[0].Id;

		//List to hold Wrappwe
		List<GoogleChartWrapper> gCW = new List<GoogleChartWrapper>();

		//Values of Wrapper
		GoogleChartWrapper gC = new GoogleChartWrapper();
		gC.firstFieldAPINameStr = 'Actual_Completion_Date__c';
		gC.secondFieldAPINameStr = 'Closed_Date__c';
		gC.thirdFieldAPINameStr = 'Code_Config_Completed__c';
		gC.fourthFieldAPINameStr = 'CR_Nickname__c';
		gC.fifthFieldAPINameStr = 'Functionality__c';
		gC.sixthFieldAPINameStr = 'Next_Steps__c';
		gC.seventhFieldAPINameStr = 'Next_Update__c';
		gC.eightFieldAPINameStr = 'OPTIONAL_Recommended_Solution__c';
		gC.ninthFieldAPINameStr = 'Roundtable_Review_Count__c';
		gC.tenthFieldAPINameStr = 'Total_Blocked_On_Hold_Issues_CRA__c';
		gC.eleventhFieldAPINameStr = 'Total_Cancelled_Issues_CRA__c';
		gC.twelveFieldAPINameStr = 'Total_Closed_Issues_CRA__c';
		gC.firstFieldChartTitle = 'Test1';
		gC.secondFieldChartTitle = 'Test2';
		gC.thirdFieldChartTitle = 'Test3';
		gC.fourthFieldChartTitle = 'Test4';
		gC.fifthFieldChartTitle = 'Test5';
		gC.sixthFieldChartTitle = 'Test6';
		gC.seventhFieldChartTitle= 'Test7';
		gC.eightFieldChartTitle = 'Test8';
		gC.ninthFieldChartTitle = 'Test9';
		gC.tenthFieldChartTitle = 'Test10';
		gC.eleventhFieldChartTitle = 'Test11';
		gC.twelveFieldChartTitle= 'Test12';    	
    	gC.firstFieldValue = 1;
		gC.secondFieldValue= 12;
		gC.thirdFieldValue = 10;
		gC.fourthFieldValue= 12;
		gC.fifthFieldValue= 12;
		gC.sixthFieldValue= 12;
		gC.seventhFieldValue= 12;
		gC.eightFieldValue = 11;
		gC.ninthFieldValue= 12;
		gC.tenthFieldValue= 12;
		gC.eleventhFieldValue= 12;
		gC.twelveFieldValue= 12;

		//Add record to list
		gCW.add(gC);	

		//Hold wrapper	
		pieGoogleChart.chartWrapperInstances = gCW;
		pieGoogleChart.init();

		//Testing Stop here
		Test.StopTest();
        
		Util.ByPassDLRSForTest = false;
	}
}