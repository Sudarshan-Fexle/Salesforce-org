/**
 *  Description      :  The test class for the PayableCreditNoteValController and PayableCreditNoteValListController
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   2/6/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 *                      
 *
 **/

@isTest
private class Test_PayableCreditNoteInvoiceController {

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
	
	@isTest static void testPayableCreditNoteValidateApproval() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		System.runAs(user1) {

		//Create the Account needed later for Payable Credit Note
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Grab the General Ledger Account created
		c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

		//Grab the Dimension 1 record from our Test Data Setup
		c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

		//Create our test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id
			);

		insert payCredNote;

		List<c2g__codaPurchaseCreditNoteExpLineItem__c> payCredNoteExpLineItems = new List<c2g__codaPurchaseCreditNoteExpLineItem__c>();
		c2g__codaPurchaseCreditNoteExpLineItem__c payCredNoteExpLineItem1 = new c2g__codaPurchaseCreditNoteExpLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__PurchaseCreditNote__c = payCredNote.Id,
			c2g__NetValue__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id
			);
		c2g__codaPurchaseCreditNoteExpLineItem__c payCredNoteExpLineItem2 = new c2g__codaPurchaseCreditNoteExpLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__PurchaseCreditNote__c = payCredNote.Id,
			c2g__NetValue__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id
			);
		payCredNoteExpLineItems.add(payCredNoteExpLineItem1);
		payCredNoteExpLineItems.add(payCredNoteExpLineItem2);
		insert payCredNoteExpLineItems;

		ApexPages.StandardController stdController = new ApexPages.StandardController(payCredNote);
		PayableCreditNoteValController payCredNoteController = new PayableCreditNoteValController(stdController);

		payCredNoteController.validateApproval();
		List<ApexPages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1, msgs.size());
        payCredNoteController.cancel();

    	}

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;

        System.runAs(poster){
        //Need to give the test user the custom permission to Approve Payable Credit Note
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Credit Note - Permission to Approve'];

        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission.Id);
        insert assignPS;

        }

        System.runAs(approver) {

        	//Grab our record and approve it
        	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, ffbext__Approved__c FROM c2g__codaPurchaseCreditNote__c WHERE c2g__AccountCreditNoteNumber__c = '13'];
            payCredNote.ffbext__Approved__c = true;

            update payCredNote;
            System.assertEquals(true, payCredNote.ffbext__Approved__c);
        }

        System.runAs(poster) {

        	//Grab our record and approve it
        	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, ffbext__Approved__c FROM c2g__codaPurchaseCreditNote__c WHERE c2g__AccountCreditNoteNumber__c = '13'];

        	//Create our controllers for testing
        	ApexPages.StandardController stdController = new ApexPages.StandardController(payCredNote);
			PayableCreditNoteValController payCredNoteController = new PayableCreditNoteValController(stdController);

            payCredNoteController.validateApproval();

        }

	}
	
	@isTest static void testPayableCreditNoteValListValidateApproval() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnablePayableCreditNoteApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;

		System.runAs(user1) {

		//Create the Account needed later for Payable Credit Note
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Grab the General Ledger Account created
		c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

		//Grab the Dimension 1 record from our Test Data Setup
		c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

		//Create our test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'test approval'
			);

		insert payCredNote;

		List<c2g__codaPurchaseCreditNoteExpLineItem__c> payCredNoteExpLineItems = new List<c2g__codaPurchaseCreditNoteExpLineItem__c>();
		c2g__codaPurchaseCreditNoteExpLineItem__c payCredNoteExpLineItem1 = new c2g__codaPurchaseCreditNoteExpLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__PurchaseCreditNote__c = payCredNote.Id,
			c2g__NetValue__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id
			);
		c2g__codaPurchaseCreditNoteExpLineItem__c payCredNoteExpLineItem2 = new c2g__codaPurchaseCreditNoteExpLineItem__c (
			c2g__GeneralLedgerAccount__c = gla1.Id,
			c2g__PurchaseCreditNote__c = payCredNote.Id,
			c2g__NetValue__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True,
			c2g__DeriveLineNumber__c = True,
			c2g__Dimension1__c = dim1.Id
			);
		payCredNoteExpLineItems.add(payCredNoteExpLineItem1);
		payCredNoteExpLineItems.add(payCredNoteExpLineItem2);
		insert payCredNoteExpLineItems;

		List<c2g__codaPurchaseCreditNote__c> payCredNoteList = new List<c2g__codaPurchaseCreditNote__c>();

		//Create our second test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote2 = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id
			);

		insert payCredNote2;
		payCredNoteList.add(payCredNote);
		payCredNoteList.add(payCredNote2);

		ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(payCredNoteList);
		PayableCreditNoteValListController payCredNoteListController = new PayableCreditNoteValListController(stdController);

		try {
            // Should throw and exception because the approver is the same as the creator.
            payCredNote2.ffbext__Approved__c = true;
            update payCredNote2;
            
        }
        catch (Exception e) {
            c2g__codaPurchaseCreditNote__c unapprovedPayCredNote = [
                select ffbext__Approved__c, Approval_Changed_By__c
                from c2g__codaPurchaseCreditNote__c
                where Id = :payCredNote2.Id
            ];

            System.assertEquals(false, unapprovedPayCredNote.ffbext__Approved__c);
       		}

   		}

		//Create the users we need for our tests
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;

        System.runAs(poster){

        //Assign our user as a Royall Process user
        PermissionSet customPermission1 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Credit Note - Permission to Approve'];  

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Credit Note - Permission to Post'];

        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);
        PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission3.Id);
        PermissionSetAssignment assignPS4 = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission1.Id);
        List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
        allPermissionSetAssignments.add(assignPS2);
        allPermissionSetAssignments.add(assignPS3);
        allPermissionSetAssignments.add(assignPS4);
        insert allPermissionSetAssignments;

        }

        System.runAs(approver) {

        	//Grab our record for approval
        	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, Name FROM c2g__codaPurchaseCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test approval'];
            payCredNote.ffbext__Approved__c = true;
            update payCredNote;

        }

        System.runAs(user1) {

            //Grab our list of records again
            List<c2g__codaPurchaseCreditNote__c> payCredNoteList = [SELECT Id, Name,c2g__AccountInvoiceNumber__c FROM c2g__codaPurchaseCreditNote__c WHERE c2g__AccountInvoiceNumber__c = '13'];

            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(payCredNoteList);
			PayableCreditNoteValListController payCredNoteListController = new PayableCreditNoteValListController(stdController);

            //Run throught the posting process again
            payCredNoteListController.validateApprovalList();

        }

	}

	@isTest static void testRoyallScenarios() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        //Insert Custom Setting record to enforce Approval for User1 later
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnablePayableCreditNoteApproval__c = true;
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

		//Create our test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'test approval'
			);

		insert payCredNote;

		//Create our test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote2 = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'test creator posting'
			);

		insert payCredNote2;

		//Create our test Payable Credit Note record we'll work with
		c2g__codaPurchaseCreditNote__c payCredNote3 = new c2g__codaPurchaseCreditNote__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__CreditNoteCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__CreditNoteDate__c = System.Today(),
			c2g__CreditNoteStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			c2g__AccountCreditNoteNumber__c = '13',
			ffbext__Approved__c = false,
			c2g__Dimension1__c = dim1.Id,
			c2g__CreditNoteDescription__c = 'test approver posting'
			);

		insert payCredNote3;

		}

		//Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;

        System.runAs(poster){

       	//Need to give the testing user the custom permissions to Approve & Post Payable Credit Note and also mark as a Royall process user
        PermissionSet customPermission1 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Credit Note - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Credit Note - Permission to Post'];                              

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

    	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, Name, c2g__CreditNoteDescription__c FROM c2g__codaPurchaseCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test approval'];

    	ApexPages.StandardController stdController = new ApexPages.StandardController(payCredNote);
		PayableCreditNoteValController payCredNoteController = new PayableCreditNoteValController(stdController);

		//Run the Posting Process before Approval
        payCredNoteController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
        		if (msg.getDetail() == ('This Payable Credit Note must be approved before it can be posted.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

		//Mark the record as approved
		payCredNote.ffbext__Approved__c = True;
		update payCredNote;

        //Run the Posting Process
        payCredNoteController.validateApproval();

        isMessageFound = false;

        List<ApexPages.Message> msgs2 = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs2){
        		if (msg.getDetail() == ('This Payable Credit Note cannot be posted by the Approver.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

    	}

    	System.runAs(user2){

    	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, Name, ffbext__Approved__c FROM c2g__codaPurchaseCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test creator posting'];

    	payCredNote.ffbext__Approved__c = true;
    	update payCredNote;

    	}

    	System.runAs(user1){

    	c2g__codaPurchaseCreditNote__c payCredNote = [SELECT Id, Name FROM c2g__codaPurchaseCreditNote__c WHERE c2g__CreditNoteDescription__c = 'test creator posting'];

    	ApexPages.StandardController stdController = new ApexPages.StandardController(payCredNote);
		PayableCreditNoteValController payCredNoteController = new PayableCreditNoteValController(stdController);

		//Run the Posting Process
        payCredNoteController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
        		if (msg.getDetail() == ('This Payable Credit Note cannot be posted by the Creator.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

    	}

    }
	
}