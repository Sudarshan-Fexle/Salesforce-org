/**
 *  Description      :  The test class for the SalesInvoiceApprovalValListController
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   3/24/2017
 * 
 *  Revision Logs   :   V1.0 - Created by Colin McGloin - CR-20161201-10511
 *                      
 *
 **/

@isTest
private class Test_SalesInvoiceValidation {

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
    
    @isTest static void testSalesInvoiceValidateApproval() {

        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

        //Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        System.runAs(user1) {

        //Create the Account needed later for Sales Invoice
        Account testAcc = TestUtilities.CreateNewAccount(true);
        testAcc.CurrencyIsoCode = 'USD';
        testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
        update testAcc;

        //Grab our Company due to Test Class deployment error
        c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];

        //Query for our currency from our setup data
        c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c = :testCompany.Id];

        //Grab the General Ledger Account created
        c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

        //Grab the Dimension 1 record from our Test Data Setup
        c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

        //Create the Product needed for the line items
        Program__c prog1 = TestUtilities.CreateNewProgram(true);

        //Grab the Product which is created as part of the Program creation process
        Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];

        //Create our list needed for the tests
        List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();

        //Create our test Sales Invoice record we'll work with
        c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
            c2g__Account__c = testAcc.Id,
            c2g__DueDate__c = System.today(),
            c2g__InvoiceCurrency__c = testCurrency.Id,
            c2g__InvoiceDate__c = System.Today(),
            c2g__InvoiceStatus__c = 'In Progress',
            c2g__DerivePeriod__c = True,
            c2g__Dimension1__c = dim1.Id,
            c2g__InvoiceDescription__c = 'Test List 1'
            );

        //Create our second test Sales Invoice record we'll work with
        c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(
            c2g__Account__c = testAcc.Id,
            c2g__DueDate__c = System.today(),
            c2g__InvoiceCurrency__c = testCurrency.Id,
            c2g__InvoiceDate__c = System.Today(),
            c2g__InvoiceStatus__c = 'In Progress',
            c2g__DerivePeriod__c = True,
            c2g__Dimension1__c = dim1.Id,
            c2g__InvoiceDescription__c = 'Test List 1'
            );

        salesInvoiceList.add(salesInvoice);
        salesInvoiceList.add(salesInvoice2);
        insert salesInvoiceList;

        //Grab a blank list for our first test
        List<c2g__codaInvoice__c> salesInvoiceList2 = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaInvoice__c WHERE c2g__InvoiceDescription__c = 'blank list'];

        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(salesInvoiceList2);
        SalesInvoiceApprovalValListController salesInvoiceListController = new SalesInvoiceApprovalValListController(stdController);

        //Send through blank list and get error message
        salesInvoiceListController.validateApprovalList();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail() == ('No Sales Invoices selected. Please select at least one Sales Invoice to post.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);

        //Set our boolean back to false for re-test
        isMessageFound = false;

        //Grab some real records to test for Custom Permission to be able to Post
        List<c2g__codaInvoice__c> salesInvoiceList3 = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaInvoice__c WHERE c2g__InvoiceDescription__c = 'Test List 1'];

        ApexPages.StandardSetController stdController2 = new ApexPages.StandardSetController(salesInvoiceList3);
        SalesInvoiceApprovalValListController salesInvoiceListController2 = new SalesInvoiceApprovalValListController(stdController2);

        List<ApexPages.Message> msgs2 = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs2){
                if (msg.getDetail() == ('You do not have the permission to post this record.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);

        }

        //Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;

        System.runAs(approver){
        //Need to give the test user the custom permission to Post Sales Invoices
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Sales Invoice - Permission to Post'];

        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User2.Id, PermissionSetId = customPermission.Id);
        insert assignPS;
        insert assignPS2;

        }

        system.runAs(user1){

        //Grab some real records to test for Custom Permission to be able to Post
        List<c2g__codaInvoice__c> salesInvoiceList4 = [SELECT Id, Name, c2g__InvoiceDescription__c FROM c2g__codaInvoice__c WHERE c2g__InvoiceDescription__c = 'Test List 1'];

        ApexPages.StandardSetController stdController3 = new ApexPages.StandardSetController(salesInvoiceList4);
        SalesInvoiceApprovalValListController salesInvoiceListController3 = new SalesInvoiceApprovalValListController(stdController3);

        //User should be able to go through sucessfully
        salesInvoiceListController3.validateApprovalList();

        }

        System.runAs(approver){
        //Assign our user as a Royall Process user
        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);     
        insert assignPS2;

        }
        
        system.runAs(user2){

        //Create the Account needed later for Sales Credit Note
        Account testAcc = TestUtilities.CreateNewAccount(true);
        testAcc.CurrencyIsoCode = 'USD';
        testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
        update testAcc;

        //Query for our currency from our setup data
        c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD'];

        //Grab the Dimension 1 record from our Test Data Setup
        c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

        //Create some fresh records for the User1 to Post
        c2g__codaInvoice__c salesInvoice3 = new c2g__codaInvoice__c(
            c2g__Account__c = testAcc.Id,
            c2g__DueDate__c = System.today(),
            c2g__InvoiceCurrency__c = testCurrency.Id,
            c2g__InvoiceDate__c = System.Today(),
            c2g__InvoiceStatus__c = 'In Progress',
            c2g__DerivePeriod__c = True,
            c2g__Dimension1__c = dim1.Id,
            c2g__InvoiceDescription__c = 'Test List 2'
            );

        insert salesInvoice3;

        }

        system.runAs(user1){

        //Create another list
        List<c2g__codaInvoice__c> salesInvoiceList5 = [SELECT Id, Name, c2g__InvoiceDescription__c
                                                           FROM c2g__codaInvoice__c 
                                                           WHERE c2g__InvoiceDescription__c = 'Test List 2'];

        ApexPages.StandardSetController stdController4 = new ApexPages.StandardSetController(salesInvoiceList5);
        SalesInvoiceApprovalValListController salesInvoiceListController4 = new SalesInvoiceApprovalValListController(stdController4);

        //Try posting again
        salesInvoiceListController4.validateApprovalList();

        }

    }
    
}