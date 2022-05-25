@isTest
private class Test_AttributeIcons {

	//public static Id isSCId;
	//public static Id sfdcRelId;
	//public static Id sfdcCRId;
	//public static Id isSMId;
	public static final string isscName = 'This ThisCrazyTestField';

    @testSetup
    static void setup() {
        
        Util.ByPassDLRSForTest = true;
        
        //create the is system component
        IS_System_Component__c isSC = new IS_System_Component__c(RecordTypeId = Schema.SObjectType.IS_System_Component__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId(),
                                              Name = 'will-autopopulate',
                                              Object_Type__c = 'Custom Field',
                                              Object_Label__c = isscName,
                                              Object_API_Name__c = isscName,
                                              Integration_Use__c = TRUE,
                                              Managed_Package_Related__c = TRUE,
                                              SOX_Object__c = TRUE,
											  ES_Core_Related__c = TRUE,
											  ES_Marketing_Related__c = TRUE,
											  Integration_Details__c = 'Test Description');
        insert isSC;
        //isSCId = isSC.Id;
        
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
                
        //create the release
        SFDC_Release__c sfdcRel = new SFDC_Release__c(Name = 'Test Release 2',
                                                      Status__c = 'Scheduled - Planned',
                                                      Environment_Manager__c = usr.Id,
                                                      Release_Manager__c = usr.Id,
                                                      Dev_Sandbox__c = devEnv[0].Id,
                                                      QA_Sandbox__c = devEnv2[1].Id,
                                                      UAT_Sandbox__c = devEnv2[1].Id,
                                                      Release_level__c = 'L2');
        insert sfdcRel;
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        //sfdcRelId = sfdcRel.Id;

        //create the change request
        //03/14/2018 - Modified By Dipesh Gupta  Q2c enhancement/bugs Release ERROR- Attempt to de-reference a null object
        SFDC_Change_Request__c sfdcCR = new SFDC_Change_Request__c(RecordTypeId = Schema.SObjectType.SFDC_Change_Request__c.getRecordTypeInfosByName().get('SFDC Change Request').getRecordTypeId(),
        									  	Title__c = 'Test Change Request',
        									  	Release__c = sfdcRel.Id,
                                                Stage__c = 'Business Review');
        insert sfdcCR;
        //sfdcCRId = sfdcCR.Id;

        //create the is system modification
        IS_System_Modification__c isSM = new IS_System_Modification__c(RecordTypeId = Schema.SObjectType.IS_System_Modification__c.getRecordTypeInfosByName().get('Complex').getRecordTypeId(),
                                                 IS_System_Component__c = isSC.Id,
                                                 Change_Request__c = sfdcCR.Id,
                                                 Type_of_Modification__c = 'Add',
                                                 High_Impact_Mod__c = TRUE,
                                                 High_Impact_Mod_Type__c = 'Deletion',
                                                 Duplicate_Mod_On_CR__c = TRUE,
                                                 Duplicate_Mod_On_Release__c = TRUE,
                                                 Double_Deployment__c = TRUE);
        insert isSM;
        //isSMId = isSM.Id;
         Util.ByPassDLRSForTest = false;
    }
	
	static testmethod void test_AttributeISSysComponentExtension() {
		
		Component.Apex.OutputPanel pnl1;
		Component.Apex.OutputPanel pnl2;
		Boolean scIntegrationUse = false;
		Boolean scManagedPackage = false;
		Boolean scSOXObject = false;
		Boolean smIntegrationUse = false;
		Boolean smManagedPackage = false;
		Boolean smSOXObject = false;
		Boolean smHighImpact = false;
		Boolean smDoubleDeployment = false;
		Boolean smDuplicateCR = false;
		Boolean smDuplicateRel = false;

		//Get the IS Sys Comp record
		//system.debug('isSCId:'+isSCId);
		//IS_System_Component__c isSysComp = [SELECT Id, Name FROM IS_System_Component__c WHERE Id = :isSCId];
		IS_System_Component__c isSysComp = [SELECT Id, Name FROM IS_System_Component__c WHERE Object_Label__c = :isscName];
		system.debug('Test_AttributeIcons.test_AttributeISSysComponentExtension - isSysComp: '+isSysComp);

		//Get the IS Sys Mod record
		IS_System_Modification__c isSysMod = [SELECT Id, Name FROM IS_System_Modification__c WHERE IS_System_Component__c = :isSysComp.Id];
		system.debug('Test_AttributeIcons.test_AttributeISSysComponentExtension - isSysMod: '+isSysMod);

		//Run the test
		test.startTest();
		
		//Test with the IS System Component record
		ApexPages.StandardController sc1 = new ApexPages.StandardController(isSysComp);
		AttributesISSysComponentExtension AttrSysCompExt1 = new AttributesISSysComponentExtension(sc1);
		//pnl1 = AttrSysCompExt1.getDynamicOutputPanel();
		scIntegrationUse = AttrSysCompExt1.isIntegration;
		scManagedPackage = AttrSysCompExt1.isManagedPackage;
		scSOXObject = AttrSysCompExt1.isSOX;

		//Test with the IS System Modification record
		ApexPages.StandardController sc2 = new ApexPages.StandardController(isSysMod);
		AttributesISSysComponentExtension AttrSysCompExt2 = new AttributesISSysComponentExtension(sc2);
		//pnl2 = AttrSysCompExt2.getDynamicOutputPanel();
		smIntegrationUse = AttrSysCompExt2.isManagedPackage;
		smHighImpact = AttrSysCompExt2.isHighImpact;
		smSOXObject = AttrSysCompExt2.isSOX;
		
      
            
		test.stopTest();

		//Verify the results
		//system.assertNotEquals(null,pnl1);
		//system.assertNotEquals(null,pnl2);
		system.assertEquals(TRUE,scIntegrationUse);
		system.assertEquals(TRUE,scSOXObject);
		system.assertEquals(TRUE,smSOXObject);
		system.assertEquals(TRUE,smHighImpact);

	}
	//03/14/2018 - Modified By Dipesh Gupta  Q2c enhancement/bugs Release System.NullPointerException  
	/*static testmethod void test_AttributeChangeRequestExtension() {
		// Implement test code
	}*/
	
}