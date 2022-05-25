/**
 *  Description      :  The test class for the PayableInvoiceValController and PayableInvoiceValListController
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   1/23/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 * 					:  Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment 
 *                      
 *
 **/

@isTest
private class Test_PayableInvoiceController {

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
	
	@isTest static void testPayableInvoiceValidateApproval() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnablePayableInvoiceApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;

		System.runAs(user1) {

		//Create the Account needed later for Payable Invoice
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Create the Product needed for the line items
		Program__c prog1 = TestUtilities.CreateNewProgram(true);
		//Grab the Product which is created as part of the Program creation process
		Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

		c2g__codaPurchaseInvoice__c payInvoice = new c2g__codaPurchaseInvoice__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__InvoiceCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__InvoiceStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			ffbext__Approved__c = false
			);

		insert payInvoice;

		List<c2g__codaPurchaseInvoiceLineItem__c> payInvoiceLineItems = new List<c2g__codaPurchaseInvoiceLineItem__c>();
		c2g__codaPurchaseInvoiceLineItem__c payInvLineItem1 = new c2g__codaPurchaseInvoiceLineItem__c (
			c2g__Product__c = product1.Id,
			c2g__PurchaseInvoice__c = payInvoice.Id,
			c2g__Quantity__c = 1,
			c2g__UnitPrice__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True
			);	
		c2g__codaPurchaseInvoiceLineItem__c payInvLineItem2 = new c2g__codaPurchaseInvoiceLineItem__c (
			c2g__Product__c = product1.Id,
			c2g__PurchaseInvoice__c = payInvoice.Id,
			c2g__Quantity__c = 1,
			c2g__UnitPrice__c = 70.00,
			c2g__DeriveTaxRateFromCode__c = True
			);
		payInvoiceLineItems.add(payInvLineItem1);
		payInvoiceLineItems.add(payInvLineItem2);
		//insert payInvoiceLineItems;

		ApexPages.StandardController stdController = new ApexPages.StandardController(payInvoice);
		PayableInvoiceValController payInvController = new PayableInvoiceValController(stdController);

		//Test out running the approval and we should get an error for unapproved record
		payInvController.validateApproval();
		List<ApexPages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1, msgs.size());
        payInvController.cancel();

    	}

	}
	
	@isTest static void testPayableInvoiceValidateApprovalList() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Insert Custom Setting record for the Approver to enforce Approval in this scenario
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnablePayableInvoiceApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;

		System.runAs(user1) {

		//Create the Account needed later for Payable Invoice
		Account testAcc = TestUtilities.CreateNewAccount(true);

		//Query for our currency from our setup data
		c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

		//Create the Product needed for the line items
		Program__c prog1 = TestUtilities.CreateNewProgram(true);
		//Grab the Product which is created as part of the Program creation process
		Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

		c2g__codaPurchaseInvoice__c payInvoice = new c2g__codaPurchaseInvoice__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__InvoiceCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__InvoiceStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			ffbext__Approved__c = false,
			c2g__InvoiceDescription__c = 'test approval'
			);

		insert payInvoice;

		List<c2g__codaPurchaseInvoiceLineItem__c> payInvoiceLineItems = new List<c2g__codaPurchaseInvoiceLineItem__c>();
		c2g__codaPurchaseInvoiceLineItem__c payInvLineItem1 = new c2g__codaPurchaseInvoiceLineItem__c (
			c2g__Product__c = product1.Id,
			c2g__PurchaseInvoice__c = payInvoice.Id,
			c2g__Quantity__c = 1,
			c2g__UnitPrice__c = 50.00,
			c2g__DeriveTaxRateFromCode__c = True
			);
		c2g__codaPurchaseInvoiceLineItem__c payInvLineItem2 = new c2g__codaPurchaseInvoiceLineItem__c (
			c2g__Product__c = product1.Id,
			c2g__PurchaseInvoice__c = payInvoice.Id,
			c2g__Quantity__c = 1,
			c2g__UnitPrice__c = 70.00,
			c2g__DeriveTaxRateFromCode__c = True
			);
		payInvoiceLineItems.add(payInvLineItem1);
		payInvoiceLineItems.add(payInvLineItem2);
		//insert payInvoiceLineItems;

		List<c2g__codaPurchaseInvoice__c> payInvList = new List<c2g__codaPurchaseInvoice__c>();
        payInvList.add(payInvoice);

        c2g__codaPurchaseInvoice__c payInvoice2 = new c2g__codaPurchaseInvoice__c(
			c2g__Account__c = testAcc.Id,
			c2g__DueDate__c = System.today(),
			c2g__InvoiceCurrency__c = testCurrency.Id,
			c2g__InvoiceDate__c = System.Today(),
			c2g__InvoiceStatus__c = 'In Progress',
			c2g__AccountInvoiceNumber__c = '13',
			ffap__DerivePeriod__c = True,
			ffbext__Approved__c = false
			);

        insert payInvoice2;
        payInvList.add(payInvoice2);

        //Grab a blank list for our first test
       	List<c2g__codaPurchaseInvoice__c> payInvList2 = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'blank list'];

       	ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(payInvList2);
		PayableInvoiceValListController PayInvoiceListController = new PayableInvoiceValListController(stdController);

		//Send through blank list and get error message
		PayInvoiceListController.validateApprovalList();

		boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
        		if (msg.getDetail() == ('No Payable Invoices selected. Please select at least one Payable Invoice to post.'))
        			 isMessageFound = true;
    					}
    	system.assertEquals(true, isMessageFound);

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
        //Need to give the test user the custom permission to Approve Payable Invoice
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Invoice - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Payable Invoice - Permission to Post']; 

        List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = user1.Id, PermissionSetId = customPermission2.Id);
        PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = user1.Id, PermissionSetId = customPermission3.Id);
        allPermissionSetAssignments.add(assignPS);
        allPermissionSetAssignments.add(assignPS2);
        allPermissionSetAssignments.add(assignPS3);
        insert allPermissionSetAssignments;

        }

        System.runAs(approver) {

        	c2g__codaPurchaseInvoice__c payInvoice = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'test approval'];

        	payInvoice.ffbext__Approved__c = true;
            update payInvoice;

            //Test that the record was approved
        	System.assertEquals(true, payInvoice.ffbext__Approved__c);

        }

        System.runAs(user1){

        c2g__codaPurchaseInvoice__c payInvoice = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'test approval'];

        //Grab a blank list for our first test
       	List<c2g__codaPurchaseInvoice__c> payInvList2 = [SELECT Id, Name, c2g__AccountInvoiceNumber__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__AccountInvoiceNumber__c = '13'];

       	ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(payInvList2);
		PayableInvoiceValListController PayInvoiceListController = new PayableInvoiceValListController(stdController);

		PayInvoiceListController.validateApprovalList();

		PayInvoiceListController.back();

    	}

	}

	@isTest static void testRoyallScenarios() {

		//Grab the User for running the Test
		User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

		//Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        //Insert Custom Setting record to enforce Approval for User1 later
		ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
		onetouchsetting1.ffbext__EnablePayableInvoiceApproval__c = true;
		onetouchsetting1.SetupOwnerId = User1.Id;
		insert onetouchsetting1;
		
		System.runAs(user1) {
    
            //Create the Account needed later for Payable Invoice
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
    
            //Create our test Payable Invoice record we'll work with
            c2g__codaPurchaseInvoice__c payInvoice = new c2g__codaPurchaseInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__AccountInvoiceNumber__c = '13',
                ffap__DerivePeriod__c = True,
                ffbext__Approved__c = false,
                c2g__InvoiceDescription__c = 'Test Approving'
                );
    
            insert payInvoice;
    
            c2g__codaPurchaseInvoice__c payInvoice2 = new c2g__codaPurchaseInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__AccountInvoiceNumber__c = '13',
                ffap__DerivePeriod__c = True,
                ffbext__Approved__c = false,
                c2g__InvoiceDescription__c = 'test Creator approval'
                );
    
            insert payInvoice2;
    
            c2g__codaPurchaseInvoice__c payInvoice3 = new c2g__codaPurchaseInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__AccountInvoiceNumber__c = '13',
                ffap__DerivePeriod__c = True,
                ffbext__Approved__c = false,
                c2g__InvoiceDescription__c = 'Test Approver Posting'
                );
    
            insert payInvoice3;

		}
		
		//Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User poster = testUtilities.CreateNewUser(p, False);
        poster.LastName = 'Poster';
        insert poster;
 		
        //Added by Mahendra Swarnkar - 06/20/2017 - As per the Run All Test in the Test SB - Starts from here
        //Create a user for Approving the payable invoices
        User approver = testUtilities.CreateNewUser(p, False);
        approver.LastName = 'Approver';
        Insert approver;
        //Added by Mahendra Swarnkar - 06/20/2017 - As per the Run All Test in the Test SB - ends here
        
        System.runAs(poster){
    
            //Need to give the testing user the custom permissions to Approve & Post Sales Credit Note and also mark as a Royall process user
            PermissionSet customPermission1 = [SELECT Id, Label 
                                              FROM PermissionSet
                                              WHERE Label = 'Payable Invoice - Permission to Approve'];
    
            PermissionSet customPermission2 = [SELECT Id, Label 
                                              FROM PermissionSet
                                              WHERE Label = 'Royall FinancialForce Process'];
    
            PermissionSet customPermission3 = [SELECT Id, Label 
                                              FROM PermissionSet
                                              WHERE Label = 'Payable Invoice - Permission to Post'];                              
    
            List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
            PermissionSetAssignment assignPS1 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission1.Id);
            PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);
            PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission3.Id);
            PermissionSetAssignment assignPS4 = new PermissionSetAssignment (AssigneeId = User2.Id, PermissionSetId = customPermission1.Id);
            
            //Added by Mahendra Swarnkar - 06/20/2017 - As per the Run All Test in the Test SB - Starts from here
            PermissionSetAssignment assignPS5 = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission1.Id);
            PermissionSetAssignment assignPS6 = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission2.Id);
            //PermissionSetAssignment assignPS7 = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission3.Id);
            allPermissionSetAssignments.add(assignPS5);
            allPermissionSetAssignments.add(assignPS6);
            //allPermissionSetAssignments.add(assignPS7); 
            //Added by Mahendra Swarnkar - 06/20/2017 - As per the Run All Test in the Test SB - Ends here
            
            allPermissionSetAssignments.add(assignPS1);
            allPermissionSetAssignments.add(assignPS2);
            allPermissionSetAssignments.add(assignPS3);
            allPermissionSetAssignments.add(assignPS4);
            
            insert allPermissionSetAssignments;

    	}

        ffbext__OneTouchSettings__c onetouchsetting2 = new ffbext__OneTouchSettings__c();
		onetouchsetting2.ffbext__EnablePayableInvoiceApproval__c = true;
		onetouchsetting2.SetupOwnerId = approver.Id;
		insert onetouchsetting2;
        
        System.runAs(approver){

            c2g__codaPurchaseInvoice__c payableInvoice = [SELECT Id, Name,ffbext__Approved__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'Test Approving'];
    
            ApexPages.StandardController stdController = new ApexPages.StandardController(payableInvoice);
            PayableInvoiceValController payInvController = new PayableInvoiceValController(stdController);
    
            //Run the Posting Process before Approval
            payInvController.validateApproval();
    
            boolean isMessageFound = false;
    
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail() == ('This Payable Invoice must be approved before it can be posted.'))
                    isMessageFound = true;
            }
            
            system.assertEquals(true, isMessageFound);
    
            //Mark the record as approved
            payableInvoice.ffbext__Approved__c = True;
            update payableInvoice;
    
            //Run the Posting Process
            payInvController.validateApproval();
    
            isMessageFound = false;
    
            List<ApexPages.Message> msgs2 = ApexPages.getMessages();
                for(Apexpages.Message msg:msgs2){
                    if (msg.getDetail() == ('This Payable Invoice cannot be posted by the Approver.'))
                         isMessageFound = true;
                            }
            system.assertEquals(true, isMessageFound);
    
    	}

    	System.runAs(user2){

            c2g__codaPurchaseInvoice__c payableInvoice = [SELECT Id, Name FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'test Creator approval'];
    
            payableInvoice.ffbext__Approved__c = true;
            update payableInvoice;

    	}

    	System.runAs(user1){

            c2g__codaPurchaseInvoice__c payableInvoice = [SELECT Id, Name FROM c2g__codaPurchaseInvoice__c WHERE c2g__InvoiceDescription__c = 'test Creator approval'];
    
            ApexPages.StandardController stdController = new ApexPages.StandardController(payableInvoice);
            PayableInvoiceValController payInvController = new PayableInvoiceValController(stdController);
    
            //Run the Posting Process
            payInvController.validateApproval();
    
            boolean isMessageFound = false;
    
            List<ApexPages.Message> msgs = ApexPages.getMessages();
                for(Apexpages.Message msg:msgs){
                    if (msg.getDetail() == ('This Payable Invoice cannot be posted by the Creator.'))
                         isMessageFound = true;
                            }
            system.assertEquals(true, isMessageFound);
    	}
    }	
}