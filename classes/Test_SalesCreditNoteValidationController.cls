/**
 *  Description      :  The test class for the SalesCreditNoteValidationController and SalesCredNoteValListController
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   3/23/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 * 					:   V1.1 - 
 *                      
 *
 **/

@isTest
private class Test_SalesCreditNoteValidationController {

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
	
	@isTest static void testSalesCreditNoteValidateApproval() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		System.runAs(user1) {

		//Create the Account needed later for Sales Credit Note
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Grab the General Ledger Account created
		c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

		//Grab the Dimension 1 record from our Test Data Setup
		c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

		//Create the Product needed for the line items
    	Program__c prog1 = TestUtilities.CreateNewProgram(true);

    	//Grab the Product which is created as part of the Program creation process
    	Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

		//Create our test Sales Credit Note record we'll work with
		c2g__codaCreditNote__c salesCredNote = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id
			);

		insert salesCredNote;

		List<c2g__codaCreditNoteLineItem__c> salesCredNoteLineItems = new List<c2g__codaCreditNoteLineItem__c>();
		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems1 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);
		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems2 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);
		salesCredNoteLineItems.add(salesCredNoteLineItems1);
		salesCredNoteLineItems.add(salesCredNoteLineItems2);
		//insert salesCredNoteLineItems;

		ApexPages.StandardController stdController = new ApexPages.StandardController(salesCredNote);
		SalesCreditNoteValidationController salesCredNoteController = new SalesCreditNoteValidationController(stdController);

        //Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnableSalesCreditNoteApproval__c = true;
		onetouchsetting1.SetupOwnerId = user1.Id;
		insert onetouchsetting1;

		//First run without the Permission Set assignment for Approval
		salesCredNoteController.validateApproval();
		List<ApexPages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1, msgs.size());
        salesCredNoteController.cancel();

    	}

        //Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;

        System.runAs(approver){
        //Need to give the test user the custom permission to Approve Sales Credit Note
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Credit Note - Permission to Approve'];

        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission.Id);
        insert assignPS;

		}

		Test.startTest();

		System.runAs(user1){

		c2g__codaCreditNote__c salesCredNote = [SELECT Id, Name FROM c2g__codaCreditNote__c LIMIT 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController(salesCredNote);
		SalesCreditNoteValidationController salesCredNoteController = new SalesCreditNoteValidationController(stdController);

        //Mark our record as Approved
        salesCredNote.ffbext__Approved__c = true;
        update salesCredNote;

        salesCredNoteController.validateApproval();

        c2g__codaCreditNote__c testRecord = [SELECT Id, Name, ffbext__Approved__c
        									  FROM c2g__codaCreditNote__c
        									  WHERE Id = :salesCredNote.Id];
        	System.assertEquals(true, salesCredNote.ffbext__Approved__c);

        }

        Test.stopTest();

	}
	
	@isTest static void testSalesCreditNoteValListValidateApproval() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        //Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnableSalesCreditNoteApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;

		//Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting2 = new ffbext__OneTouchSettings__c();
		onetouchsetting2.ffbext__EnableSalesCreditNoteApproval__c = true;
		onetouchsetting2.SetupOwnerId = User2.Id;
		insert onetouchsetting2;

		System.runAs(user1) {

		//Create the Account needed later for Sales Credit Note
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Grab the General Ledger Account created
		c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

		//Grab the Dimension 1 record from our Test Data Setup
		c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

		//Create the Product needed for the line items
    	Program__c prog1 = TestUtilities.CreateNewProgram(true);

    	//Grab the Product which is created as part of the Program creation process
    	Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

    	//Create our list needed for the tests
    	List<c2g__codaCreditNote__c> salesCredNoteList = new List<c2g__codaCreditNote__c>();

		//Create our test Sales Credit Note record we'll work with
		c2g__codaCreditNote__c salesCredNote = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Test List 1'
			);

		//Create our second test Sales Credit Note record we'll work with
		c2g__codaCreditNote__c salesCredNote2 = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Test List 1'
			);

		//Creat our third Sales Credit Note for later
		c2g__codaCreditNote__c salesCredNote3 = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Test List 2'
			);

		//Creat our fourth Sales Credit Note for later
		c2g__codaCreditNote__c salesCredNote4 = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Approved by user2'
			);

		salesCredNoteList.add(salesCredNote);
		salesCredNoteList.add(salesCredNote2);
		salesCredNoteList.add(salesCredNote3);
		salesCredNoteList.add(salesCredNote4);
		insert salesCredNoteList;

		List<c2g__codaCreditNoteLineItem__c> salesCredNoteLineItems = new List<c2g__codaCreditNoteLineItem__c>();

		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems1 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);
		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems2 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);

		salesCredNoteLineItems.add(salesCredNoteLineItems1);
		salesCredNoteLineItems.add(salesCredNoteLineItems2);
		//insert salesCredNoteLineItems;

		}

		//Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;

        System.runAs(approver){
        //Need to give the test user the custom permission to Approve Sales Credit Note
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Credit Note - Permission to Approve'];

        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User2.Id, PermissionSetId = customPermission.Id);
        insert assignPS;
        insert assignPS2;

        }

        system.runAs(user1){

       	List<c2g__codaCreditNote__c> salesCredNoteList2 = [SELECT Id, Name FROM c2g__codaCreditNote__c WHERE c2g__CreditNoteDescription__c = 'Test List 1'];

       	ApexPages.StandardSetController stdController2 = new ApexPages.StandardSetController(salesCredNoteList2);
		SalesCredNoteValListController salesCredNoteListController2 = new SalesCredNoteValListController(stdController2);

		c2g__codaCreditNote__c salesCredNote1 = salesCredNoteList2[0];
		c2g__codaCreditNote__c salesCredNote3 = salesCredNoteList2[1];

        //Modify our records to Approved
        salesCredNote1.ffbext__Approved__c = true;
        salesCredNote3.ffbext__Approved__c = true;
        update salesCredNoteList2;

        //Try running our Approval logic
        salesCredNoteListController2.validateApprovalList();

        c2g__codaCreditNote__c testSalesCredNote2 = [
            select Name, ffbext__Approved__c, Approval_Changed_By__c, c2g__CreditNoteStatus__c
            from c2g__codaCreditNote__c
            WHERE Id = :salesCredNote1.Id
        ];

        //Test that the record was approved and not posted
        System.assertEquals(true, testSalesCredNote2.ffbext__Approved__c);
        System.assertEquals('In Progress',testSalesCredNote2.c2g__CreditNoteStatus__c);

    	}

        System.runAs(approver){
        //Assign our user as a Royall Process user
        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Credit Note - Permission to Post'];  

        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);
        PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission3.Id);
        List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
        allPermissionSetAssignments.add(assignPS2);
        allPermissionSetAssignments.add(assignPS3);
        insert allPermissionSetAssignments;
        }

        //Run through the scenario where the user tries to post when the records are not marked as approved
        system.runAs(user1){

		//Create another list
		List<c2g__codaCreditNote__c> salesCredNoteList3 = [SELECT Id, c2g__CreditNoteDescription__c 
														   FROM c2g__codaCreditNote__c 
														   WHERE c2g__CreditNoteDescription__c = 'Test List 2'];

		ApexPages.StandardSetController stdController3 = new ApexPages.StandardSetController(salesCredNoteList3);
		SalesCredNoteValListController salesCredNoteListController3 = new SalesCredNoteValListController(stdController3);

		//Try posting again
		salesCredNoteListController3.validateApprovalList();

        }

        System.runAs(user2){

        //Update one of our records to Approved
		c2g__codaCreditNote__c salesCredNote1 = [SELECT Id, ffbext__Approved__c, Approval_Changed_By__c, Approval_Changed_By_Date__c, c2g__CreditNoteDescription__c 
												 FROM c2g__codaCreditNote__c 
												 WHERE c2g__CreditNoteDescription__c = 'Approved by user2'];

		//Mark our record as Approved										 
		salesCredNote1.ffbext__Approved__c = True;
		update salesCredNote1;

		//Check our approval went through
		System.assertEquals(true, salesCredNote1.ffbext__Approved__c);
        }

        system.runAs(user1){

		//Create another list
		List<c2g__codaCreditNote__c> salesCredNoteList3 = [SELECT Id, c2g__CreditNoteDescription__c 
														   FROM c2g__codaCreditNote__c 
														   WHERE c2g__CreditNoteDescription__c = 'Approved by user2'];

		ApexPages.StandardSetController stdController3 = new ApexPages.StandardSetController(salesCredNoteList3);
		SalesCredNoteValListController salesCredNoteListController3 = new SalesCredNoteValListController(stdController3);

		//Try posting again
		salesCredNoteListController3.validateApprovalList();

        }

	}

	@isTest static void testRoyallScenarios() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        //Insert Custom Setting record to enforce Approval for User1 later
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnableSalesCreditNoteApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;

		System.runAs(user1) {

		//Create the Account needed later for Sales Credit Note
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Grab the General Ledger Account created
		c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

		//Grab the Dimension 1 record from our Test Data Setup
		c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

		//Create the Product needed for the line items
    	Program__c prog1 = TestUtilities.CreateNewProgram(true);

    	//Grab the Product which is created as part of the Program creation process
    	Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

    	//Create our test Sales Credit Note record we'll work with
		c2g__codaCreditNote__c salesCredNote = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Test Approval Scenario'
			);

		insert salesCredNote;

		c2g__codaCreditNote__c salesCredNote2 = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'Test Approver Posting'
			);

		insert salesCredNote2;

		c2g__codaCreditNote__c salesCredNote3 = new c2g__codaCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'test Creator approval'
			);

		insert salesCredNote3;

		List<c2g__codaCreditNoteLineItem__c> salesCredNoteLineItems = new List<c2g__codaCreditNoteLineItem__c>();
		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems1 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);
		c2g__codaCreditNoteLineItem__c salesCredNoteLineItems2 = new c2g__codaCreditNoteLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__CreditNote__c = salesCredNote.Id,
			c2g__UnitPrice__c = 50.00,
			c2g__Quantity__c = 1,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id,
			c2g__Product__c = product1.Id
			);
		salesCredNoteLineItems.add(salesCredNoteLineItems1);
		salesCredNoteLineItems.add(salesCredNoteLineItems2);
		//insert salesCredNoteLineItems;

		}

		//Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;

        System.runAs(poster){

       	//Need to give the testing user the custom permissions to Approve & Post Sales Credit Note and also mark as a Royall process user
        PermissionSet customPermission1 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Credit Note - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Credit Note - Permission to Post'];                              

        List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPS1 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission1.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);
        PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission3.Id);
        PermissionSetAssignment assignPS4 = new PermissionSetAssignment (AssigneeId = User2.Id, PermissionSetId = customPermission1.Id);
        allPermissionSetAssignments.add(assignPS1);
        allPermissionSetAssignments.add(assignPS2);
        allPermissionSetAssignments.add(assignPS3);
        allPermissionSetAssignments.add(assignPS4);
        insert allPermissionSetAssignments;

    	}

    	System.runAs(user1){

    	c2g__codaCreditNote__c salesCredNote = [SELECT Id, Name FROM c2g__codaCreditNote__c WHERE c2g__CreditNoteDescription__c = 'Test Approval Scenario'];

    	ApexPages.StandardController stdController = new ApexPages.StandardController(salesCredNote);
		SalesCreditNoteValidationController salesCredNoteController = new SalesCreditNoteValidationController(stdController);

		//Run the Posting Process before Approval
        salesCredNoteController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
        		if (msg.getDetail() == ('This Sales Credit Note must be approved before it can be posted.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

		//Mark the record as approved
		salesCredNote.ffbext__Approved__c = True;
		update salesCredNote;

        //Run the Posting Process
        salesCredNoteController.validateApproval();

        isMessageFound = false;

        List<ApexPages.Message> msgs2 = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs2){
        		if (msg.getDetail() == ('This Sales Credit Note cannot be posted by the Approver.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

    	}

    	System.runAs(user2){

    	c2g__codaCreditNote__c salesCredNote = [SELECT Id, Name FROM c2g__codaCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test Creator approval'];

    	salesCredNote.ffbext__Approved__c = true;
    	update salesCredNote;

    	}

    	System.runAs(user1){

    	c2g__codaCreditNote__c salesCredNote = [SELECT Id, Name FROM c2g__codaCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test Creator approval'];

    	ApexPages.StandardController stdController = new ApexPages.StandardController(salesCredNote);
		SalesCreditNoteValidationController salesCredNoteController = new SalesCreditNoteValidationController(stdController);

		//Run the Posting Process
        salesCredNoteController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
        		if (msg.getDetail() == ('This Sales Credit Note cannot be posted by the Creator.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

    	}

    }
	
}