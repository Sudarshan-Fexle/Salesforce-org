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
@isTest(seeAllData = false)
private class TestBatch_RoyallShiftAccountStatus {
	
/**
 *	@Purpose		:	Test class for tetsing Batch(Batch_RoyallShiftAccountStatus)functionalityis using to Upadte information on Account realted to Program Package/HD	
 *
 *	@Created By		:	Subhash Garhwal		
 *
 *	@Created Date	:	07-08-2016	
 *
 *	@Rivision Log	:	V1.0 - Created
 *						V_1.1 - Moved - 9/20/2016 - Subhash Garhwal - CR-20160817-10134 - Moved class from Royall Instance	
						V_1.2 - Modified By Abhinav sharma - CR-20180809-12493 - Removed the references of Royall Record types Undergrad and Advancement.
 *
**/
    static testMethod void myUnitTest() {
        
        //Bypass all the triggers 
        Util.BypassAllTriggers = true;
        
        //Added - Subhash Garhwal - 9/20/2016 - CR-20160817-10134
        List<RecordType> recordTypes = [Select Id From RecordType 
                                        	Where SobjectType = 'Account' 
                                        	AND DeveloperName IN ('Royall_Admissions_Graduate'/*, 'Royall_Admissions_Undergraduate', 'Royall_Advancement'*/) 
                                        	LIMIT 3];
        List<RecordType> recordTypesPP = [Select Id From RecordType 
                                          	Where SobjectType = 'Program_Package__c' 
                                          	AND DeveloperName IN ('Royall', 'Hardwick_Day') 
                                          	ORDER BY DeveloperName ASC
                                          	LIMIT 2];
        //Account test data
        List<Account> accounts = new List<Account>();
        
        //Account data
        accounts.add(new Account(Name = 'Test1', RecordTypeId = recordTypes[0].Id));
        accounts.add(new Account(Name = 'Test2', RecordTypeId = recordTypes[0].Id));
        
        //Insert Account
        insert accounts;
        
        Integer currentFY = shift_get_fiscal_year.current();  
        
        //Query list of Accounts
        List<Account> accs = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
										r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
										r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
   										r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account];
   		
   		//Assert
   		System.assertEquals(Null,accs[0].r_Previous_Year_Account_Status__c);
   		
   		//List of program Package						
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		//Test data of  Program Package
		progPacks.add(new Program_Package__c(Name = 'PackageT1', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
											Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[1].ID));
		progPacks.add(new Program_Package__c(Name = 'PackageT2', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
											Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[1].ID));
		progPacks.add(new Program_Package__c(Name = 'PackageT3', Account__c = accs[0].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
											Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[1].ID));
		
		progPacks.add(new Program_Package__c(Name = 'PackageT11', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
											Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[1].ID));
		progPacks.add(new Program_Package__c(Name = 'PackageT12', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
											Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[1].ID));
		progPacks.add(new Program_Package__c(Name = 'PackageT13', Account__c = accs[1].Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
											Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[1].ID));
        
        //test data of HD TypeProgram Package
		progPacks.add(new Program_Package__c(Name = 'TestHd1', Account__c =accs[0].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
    														 	Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[0].ID));
		progPacks.add(new Program_Package__c(Name = 'TestHd2', Account__c =accs[0].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
    														 	Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[0].ID));
		progPacks.add(new Program_Package__c(Name = 'TestHd3', Account__c =accs[0].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
    														 	Client_Status_New__c = 'In Play', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[0].ID));
		
		progPacks.add(new Program_Package__c(Name = 'TestHd11', Account__c =accs[1].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
    														 	Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = recordTypesPP[0].ID));
		progPacks.add(new Program_Package__c(Name = 'TestHd21', Account__c =accs[1].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
    														 	Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[0].ID));
		progPacks.add(new Program_Package__c(Name = 'TestHd31', Account__c =accs[1].Id,Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
    														 	Client_Status_New__c = 'In Play', Account_Status__c = 'New Client', RecordTypeId = recordTypesPP[0].ID));
					
		//Insert Program Package							
		insert progPacks;
        
        //Test satrt here
		Test.startTest();
		
        //Enables all the triggers
		Util.BypassAllTriggers = false;
        
		//Execute batch
   		Batch_RoyallShiftAccountStatus batch = new Batch_RoyallShiftAccountStatus();
		Database.executeBatch(batch);
   		
   		//Test Stop here
		Test.stopTest();	
		
		//Query Account records
		accs = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
										r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
										r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
   										r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account order by Name ASC];
   		
   		//Assert
   		System.assertEquals('Committed',accs[0].r_HD_Current_Year_Engagement_Status__c);
   		System.assertEquals('In Play',accs[0].r_HD_Next_Year_Engagement_Status__c);
   		System.assertEquals('Existing Client',accs[0].r_HD_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[0].r_hd_current_year_account_status__c);
   		System.assertEquals('New Client',accs[0].r_HD_Next_Year_Account_Status__c);  
   		System.assertEquals('Secured',accs[0].r_HD_Previous_Year_Engagement_Status__c);
   		
   		System.assertEquals('Committed',accs[1].r_HD_Current_Year_Engagement_Status__c);
   		System.assertEquals('In Play',accs[1].r_HD_Next_Year_Engagement_Status__c);
   		System.assertEquals('Existing Client',accs[1].r_HD_Previous_Year_Account_Status__c);
   		System.assertEquals('New Client',accs[1].r_hd_current_year_account_status__c);
   		System.assertEquals('New Client',accs[1].r_HD_Next_Year_Account_Status__c);
   		System.assertEquals('Secured',accs[1].r_HD_Previous_Year_Engagement_Status__c);				
    }
    
    /**
 *	@Purpose		:	Test class for tetsing Batch(Batch_RoyallShiftAccountStatus)functionalityis using to Upadte information on Account realted to Program Package/HD	
 *
 *	@Created By		:	Victor Hanson	
 *
 *	@Created Date	:	03-15-2017	
 *
 *	@Rivision Log	:	V1.0 - Created - CR-10692
 *
**/
    static testMethod void testRoyallAndHDPackages() {
        
        //Bypass all the triggers 
        Util.BypassAllTriggers = true;
        
        //create custom setting default so the trigger will fire to auto-populate programPackage fields
        Account_Status_Management__c acctStatusMgmt = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert acctStatusMgmt;
        
        Id PP_Royall_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        Id PP_HD_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Hardwick Day').getRecordTypeId();
        //Account data
        Account acct = new Account(Name = 'Test1', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Graduate Education').getRecordTypeId());
        //Insert Account
        insert acct;
        
        Integer currentFY = shift_get_fiscal_year.current();  
        
        //Query list of Accounts
        acct = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
										r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
										r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
   										r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account WHERE Id = :acct.Id];
   		
   		//Assert
   		System.assertEquals(null,acct.r_Previous_Year_Account_Status__c);
   		
   		//List of program Package						
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		//Test data of  Program Package
        progPacks.add(new Program_Package__c(Name = 'PackageT1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
                                             Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT3', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_Royall_RT_Id));
        
        //test data of HD TypeProgram Package
        progPacks.add(new Program_Package__c(Name = 'TestHd1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_HD_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'TestHd2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_HD_RT_Id));
        //Enables all the triggers
        Util.BypassAllTriggers = false; 
        
		//Insert Program Package							
		insert progPacks;
        
        //Test satrt here
		Test.startTest();
		
        //Enables all the triggers
		Util.BypassAllTriggers = false;
        
		//Execute batch
   		Batch_RoyallShiftAccountStatus batch = new Batch_RoyallShiftAccountStatus();
		Database.executeBatch(batch);
   		
   		//Test Stop here
		Test.stopTest();	
		
        //Query Account records
        acct = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
                r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
                r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
                r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account WHERE Id = :acct.Id];
        
        //Assert HD
        System.assertEquals('Secured',acct.r_HD_Current_Year_Engagement_Status__c);//TestHd1
        System.assertEquals('Committed',acct.r_HD_Next_Year_Engagement_Status__c);//TestHd2
        System.assertEquals(null,acct.r_HD_Previous_Year_Account_Status__c);//HD had no previous year package -> should be null
        System.assertEquals('New Client',acct.r_hd_current_year_account_status__c);//TestHd1
        System.assertEquals('Existing Client',acct.r_HD_Next_Year_Account_Status__c);//TestHd2
        
        //Assert Royall
        System.assertEquals('At Risk',acct.r_Previous_Year_Status__c);//PackageT1
        System.assertEquals('Secured',acct.r_Current_Year_Status__c);//PackageT2
        System.assertEquals('Committed',acct.r_Next_Year_Status__c);//PackageT3
        System.assertEquals('New Client',acct.r_Previous_Year_Account_Status__c);//PackageT1
        System.assertEquals('Existing Client',acct.r_Current_Year_Account_Status__c);//PackageT2
        System.assertEquals('Existing Client',acct.r_Next_Year_Account_Status__c);//PackageT3		
    }
    
    /**
 *	@Purpose		:	Test class for tetsing Batch(Batch_RoyallShiftAccountStatus)functionalityis using to Upadte information on Account realted to Program Package/HD	
 *
 *	@Created By		:	Victor Hanson	
 *
 *	@Created Date	:	03-15-2017	
 *
 *	@Rivision Log	:	V1.0 - Created - CR-10692
 *
**/
    static testMethod void testRoyallAndHDPackageTrigger() {
        
        //Bypass all the triggers 
        Util.BypassAllTriggers = true;
        
        //create custom setting default so the trigger will fire to auto-populate programPackage fields
        Account_Status_Management__c acctStatusMgmt = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert acctStatusMgmt;
        
        Id PP_Royall_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        Id PP_HD_RT_Id = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Hardwick Day').getRecordTypeId();
        //Account data
        Account acct = new Account(Name = 'Test1', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Graduate Education').getRecordTypeId());
        //Insert Account
        insert acct;
        
        Integer currentFY = shift_get_fiscal_year.current();  
        
        //Query list of Accounts
        acct = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
                r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
                r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
                r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account WHERE Id = :acct.Id];
        
        //Assert
        System.assertEquals(null,acct.r_Previous_Year_Account_Status__c);
        
        //List of program Package						
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        //Test data of  Program Package
        progPacks.add(new Program_Package__c(Name = 'PackageT1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY - 1)),
                                             Client_Status_New__c = 'At Risk', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_Royall_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'PackageT3', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_Royall_RT_Id));
        
        //test data of HD TypeProgram Package
        progPacks.add(new Program_Package__c(Name = 'TestHd1', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = 'Secured', Account_Status__c = 'Existing Client', RecordTypeId = PP_HD_RT_Id));
        progPacks.add(new Program_Package__c(Name = 'TestHd2', Account__c = acct.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = 'Committed', Account_Status__c = 'New Client', RecordTypeId = PP_HD_RT_Id));
        
        //Insert Program Package							
        Test.startTest();
        Util.BypassAllTriggers = false;
        Shift_StatusRollup_Handler.bypassSetAcctStatus = false;
        insert progPacks;
        Test.stopTest();
        
		//Query Account records
        acct = [Select Id, r_Current_Year_Status__c, r_Previous_Year_Status__c, r_Next_Year_Status__c, r_Current_Year_Account_Status__c,
                r_Previous_Year_Account_Status__c, r_Next_Year_Account_Status__c,r_HD_Previous_Year_Engagement_Status__c,
                r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Account_Status__c,
                r_hd_current_year_account_status__c, r_HD_Next_Year_Account_Status__c from Account WHERE Id = :acct.Id];
        
        //Assert HD
        System.assertEquals('Secured',acct.r_HD_Current_Year_Engagement_Status__c);//TestHd1
        System.assertEquals('Committed',acct.r_HD_Next_Year_Engagement_Status__c);//TestHd2
        System.assertEquals(null,acct.r_HD_Previous_Year_Account_Status__c);//HD had no previous year package -> should be null
        System.assertEquals('New Client',acct.r_hd_current_year_account_status__c);//TestHd1
        System.assertEquals('Existing Client',acct.r_HD_Next_Year_Account_Status__c);//TestHd2
        
        //Assert Royall
        System.assertEquals('At Risk',acct.r_Previous_Year_Status__c);//PackageT1
        System.assertEquals('Secured',acct.r_Current_Year_Status__c);//PackageT2
        System.assertEquals('Committed',acct.r_Next_Year_Status__c);//PackageT3
        System.assertEquals('New Client',acct.r_Previous_Year_Account_Status__c);//PackageT1
        System.assertEquals('Existing Client',acct.r_Current_Year_Account_Status__c);//PackageT2
        System.assertEquals('Existing Client',acct.r_Next_Year_Account_Status__c);//PackageT3		
    }
}