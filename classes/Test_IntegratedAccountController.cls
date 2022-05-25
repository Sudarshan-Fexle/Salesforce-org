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
private class Test_IntegratedAccountController {
/*
    Purpose         :   Test class for IntegratedAccountController 
                
    Create By       :   Deepak Kumar
    
    Created Date    :   07/03/2017
    
    Current Version :   V_1.0
    
    Revision Log    :   V_1.0 - Created
                        V_1.1 - Modified By - Deepak Kumawat - Apollo - Run All Test Failures Fixes 
			V_1.2 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*/
	static testMethod void myUnitTest() {
		
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
		//List of Account
        List<Account> parentAccounts = new List<Account>();
        
        //Add new account in list
        parentAccounts.add(new Account(Name = 'TestAccount', Account_Formal_Name__c = 'AAA1', Primary_City__c  = 'AA1')); 
        parentAccounts.add(new Account(Name = 'testAccount21', Account_Formal_Name__c= 'AAA2', Primary_City__c   = 'AA2'));

        //Insert    
        insert parentAccounts;

        //List to hold account
        List<Account> accounts = new List<Account>();

        //Add to list
        accounts.add(new Account(Name = 'TestAccount1', Account_Formal_Name__c = 'BBB1', ParentId = parentAccounts[0].Id, Primary_City__c = 'BB1'));
        
        //Insert child Account
        insert accounts;
        
        //List to hold Contact
        List<Contact> contacts = new List<Contact>();

        //Addd to list
        contacts.add(new Contact( AccountId = accounts[0].Id, LastName = 'ABC', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));

        //Insert Contact
        insert contacts;
		
        //Get opportunity record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN: CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES ORDER BY DeveloperName ASC];
        
		//List to hold the opportunity records  
        List<Opportunity> opportunities = new List<Opportunity>();

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list            
        //EAB_Continuing Record type Opportunity -Account AA1   
        opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING, 
                                                AccountId = accounts[0].Id, Name = 'TestOpp',Sales_Pursuit_Products__c = 'APS',
                                                Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                                RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                                CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
		
		//Insert opportunity
		insert opportunities;
		
		//List to hold integrated Account
        List<Integrated_Account__c> integAccounts = new List<Integrated_Account__c>();

        integAccounts.add(new Integrated_Account__c(Opportunity__c = opportunities[0].Id));

        //Insert integrated Account
        insert integAccounts;
		
        //Enabling the triggers
        Util.BypassAllTriggers = false;
        
		//Test start from here
		Test.startTest();
		
		// set the page reference and recordType = Other Outcome
        PageReference pageRef = Page.IntegratedAccountNewAndEdit;
        pageRef.getParameters().put('oppId', opportunities[0].Id);
        test.setCurrentPage(pageRef);
		
		//Standard Controller
		ApexPages.StandardController sc = new ApexPages.StandardController(integAccounts[0]);
		IntegratedAccountController controller = new IntegratedAccountController(sc);
		
		//Assert for results
		System.assertEquals(controller.accountId, accounts[0].Id);
		
		//Method Calling
		controller.populateAccountId();
		controller.integratedAccount = new Integrated_Account__c(Opportunity__c = opportunities[0].Id);
		controller.doSaveAndNew();
		controller.integratedAccount = null;
		controller.doSaveAndNew();
		
		//Test stop here
		Test.stopTest();
	}
}