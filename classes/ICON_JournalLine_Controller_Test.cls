/**
 *  Description      :  Test custom data entry for Journal Entry
 * 
 *  Created By      :   John McCarvill (ICON - john.mccarvill@iconatg.com)
 * 
 *  Created Date    :   3/30/2015
 * 
 *  Revision Logs   :   V1.0 - Created by John McCarvill
 *			V1.1 - Modified by Colin McGloin - CR-20161201-10511
 *			V1.2 - Modified By - Mahendra Swarnkar - 7/30/2021 - CR-20210119-14818 - Add Budget ID to Journals
 *                      
 *
 **/

@isTest ()
public with sharing class ICON_JournalLine_Controller_Test {

	@testSetup static void setup() {

		//Bypass Dupeblocker
		Util.IsTest(true);

		//Bypass Triggers
		Util.BypassAllTriggers = true;

		//Create a user for running the process
        	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        	User user1 = testUtilities.CreateNewUser(p, true);
        	user1.LastName = 'Saweda';
        	update user1;

        	// Create common test data
        	TestUtilities.setUpFinancialForceData(true, User1.Id);

    	}

	public static testMethod void testICON_JournalLine_Controller() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		System.runAs(user1) {

		//create a test payable invoice ------------------------------------------------------------------------------------
		
		//get supporting info
		Account pAccount = TestUtilities.CreateNewAccount(true);
		
		c2g__codaDimension1__c pDimension1 = [SELECT Id FROM c2g__codaDimension1__c LIMIT 1];
		
		c2g__codaCompany__c pCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
		
		c2g__codaPeriod__c pPeriod = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__StartDate__c<=:System.today() AND c2g__EndDate__c>=:System.today() LIMIT 1]; 
		
		c2g__codaAccountingCurrency__c pCurrency = [Select Id From c2g__codaAccountingCurrency__c WHERE Name='USD' LIMIT 1];
		
		c2g__codaJournal__c pJournal = new c2g__codaJournal__c(
			c2g__JournalCurrency__c = pCurrency.Id, //reference(c2g__codaAccountingCurrency__c)
			c2g__JournalDate__c = System.today(), 	//date
			c2g__JournalDescription__c = 'Test', 	//textarea(255)
			c2g__JournalStatus__c = 'In Progress', 	//picklist(255)
			c2g__OwnerCompany__c = pCompany.Id, 	//reference(c2g__codaCompany__c)
			c2g__Period__c = pPeriod.Id, 		//reference(c2g__codaPeriod__c)
			c2g__Type__c = 'Manual Journal', 	//picklist(255)
			//c2g__UnitofWork__c = 31.0, 		//number(18,0)
			ffgl__DeriveCurrency__c = false, 	//boolean
			ffgl__DerivePeriod__c = false, 		//boolean
			Registered_Date__c = system.today(), 	//date
			Approved__c = false 			//boolean
		);
		insert(pJournal);
		
		
		c2g__codaGeneralLedgerAccount__c pGL = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c LIMIT 1];
		
		//Modified By - Mahendra Swarnkar - 7/30/2021 - CR-20210119-14818 - Add Budget ID to Journals
		c2g__codaJournalLineItem__c pJournalLineItem = new c2g__codaJournalLineItem__c(
			CurrencyIsoCode = 'USD', 			//picklist(3)
			c2g__Journal__c = pJournal.Id, 			//reference(c2g__codaJournal__c)
			c2g__Dimension1__c = pDimension1.Id, 		//reference(c2g__codaDimension1__c)
			c2g__GeneralLedgerAccount__c = pGL.Id, 		//reference(c2g__codaGeneralLedgerAccount__c)
			c2g__LineDescription__c = 'Test', 		//text(255)
			c2g__LineNumber__c = 1.0, 			//number(18,0)
			c2g__LineType__c = 'General Ledger Account', 	//picklist(255)
			c2g__OwnerCompany__c = pCompany.Id, 		//reference(c2g__codaCompany__c)
			//c2g__UnitOfWork__c = 16.0, 			//number(18,0)
			c2g__Value__c = 49.2, 				//number(18,2)
			c2g__VendorValue__c = 0.0, 			//number(18,2)
			c2g__DebitCredit__c = 'Debit', 			//picklist(255)
			ffgl__DeriveLineNumber__c = false, 		//boolean
			Transaction_Date__c = system.today(), 		//date
			Budget_System_ID__c = '' 			//TEXT(32)
		);
		insert(pJournalLineItem);
 		
		//Load page using ID of invoice

        	//load the payable invoice ------------------------------------------------------------------------------------

		//Use the PageReference Apex class to instantiate a test page for this controller
		PageReference pageRef = Page.ICON_JournalLine;

		//In this case, the Visualforce page is the starting point of this test method. 
		Test.setCurrentPage(pageRef);

		//Instantiate and construct the controller class.
		ApexPages.StandardController stdController = new ApexPages.StandardController(pJournal);
		ICON_JournalLine_Controller controller = new ICON_JournalLine_Controller(stdController);

		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: LoadDetails
		controller.LoadDetails();

		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: m_sId
		string sId = controller.m_sId;
		System.assert(sId!=null);


		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: showMessage

		string stringShowMessage = 'SampleData';
		controller.showMessage = stringShowMessage;
		System.assert(true);

		stringShowMessage = controller.showMessage;
		System.assert(stringShowMessage!=null);

		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: m_pHeader

		c2g__codaJournal__c pHeader = controller.m_pHeader;
		System.assert(pHeader!=null);

		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: m_listLines

		List<c2g__codaJournalLineItem__c> listLines  = controller.m_listLines;
		System.assert(listLines.size()>0);



		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: AddLine
		integer iCount=listLines.size();
		Pagereference pagereferenceAddLine = controller.AddLine();
		System.assert(iCount!=listLines.size());  


		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: RemoveLine

		//This test function expects querystring parameters:
		//string sId = ApexPages.currentPage().getParameters().get('LineId')

		iCount=listLines.size();
		ApexPages.currentPage().getParameters().put('LineId', String.valueOf(pJournalLineItem.c2g__LineNumber__c));
		controller.RemoveLine();
		System.assert(iCount!=listLines.size());
		

		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: m_setLinesDelete

		Set<c2g__codaJournalLineItem__c> setLinesDelete  = controller.m_setLinesDelete;
		System.assert(setLinesDelete.size()!=0);


		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: Cancel

		Pagereference pagereferenceCancel = controller.Cancel();
		System.assert(pagereferenceCancel!=null);


		//--------------------------------------------------------------------------------------------------------------------
		//Unit Test Functions for: saveDocument

		//add another line
		Pagereference pagereferenceSaveDocument = controller.saveDocument();

		}
		

	}
}