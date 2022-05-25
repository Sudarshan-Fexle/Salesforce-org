/**
 *  Description      :  The test class for the JournalApprovalValidationController
 * 
 *  Created By      :   William Rich (Company:IconATG Email:william.rich@iconatg.com)
 * 
 *  Created Date    :   3/21/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified by Colin McGloin - CR-20161201-10511
 * 						//Modified By  Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment 
 *                      
 *
 **/
  
@isTest()
private class JournalApprovalValidationControllerTest {

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
    
    static testMethod void testJournalApprovalValidation() {

        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

        System.runAs(user1) {

         c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test approval'
        );
        insert journal;

        c2g__codaJournal__c journal2 = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert journal2;

        //Grab the General Ledger Account created
        c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

        //Grab the Dimension 1 record from our Test Data Setup
        c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

        Decimal amount = 10.0;
        List<c2g__codaJournalLineItem__c> jLineItems = new List<c2g__codaJournalLineItem__c>();
        c2g__codaJournalLineItem__c jLineItem_1 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 1,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = gla1.Id,
            c2g__Value__c = amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_1);

        c2g__codaJournalLineItem__c jLineItem_2 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 2,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = gla1.Id,
            c2g__Value__c = -amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_2);
        insert jLineItems;
		
		Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(journal2);
        JournalApprovalValidationController journalController = new JournalApprovalValidationController(stdController);

        journalController.validateApproval();
        List<ApexPages.Message> msgs = ApexPages.getMessages();
        c2g__codaJournal__c journal_2 = [SELECT Name, c2g__JournalStatus__c FROM c2g__codaJournal__c WHERE Id = :journal2.Id];
        journalController.cancel();

        }

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        update approver;
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;


        System.runAs(poster){
        //Need to give the test user the custom permission to Approve Journal
        //Grab our Permission Set with the Custom Permission to Approve and assign to our Approver
        PermissionSet customPermission = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Post'];

        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = poster.Id, PermissionSetId = customPermission2.Id);
        insert assignPS;
        insert assignPS2;

        }

        System.runAs(approver) {

            c2g__codaJournal__c journal = [SELECT Name, Approved__c, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test approval'];
            journal.Approved__c = true;
            update Journal;

            //Check the record was approved correctly
            System.assertEquals(true, journal.Approved__c); 

        }

        System.runAs(poster) {

            //Run through the post process now
            c2g__codaJournal__c journal = [SELECT Name, Approved__c, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test approval'];

            ApexPages.StandardController stdController = new ApexPages.StandardController(journal);
            JournalApprovalValidationController journalController = new JournalApprovalValidationController(stdController);

            journalController.validateApproval();

        }  
		Test.stopTest();
    }
    
    static testMethod void testJournalApprovalValidationList() {

        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

        //Insert Custom Setting record to enforce Approval for User1 later
        ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
        onetouchsetting1.EnableJournalApproval__c = true;
        onetouchsetting1.SetupOwnerId = User1.Id;
        insert onetouchsetting1;

        System.runAs(user1) {

         c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test record'
        );
        insert journal;

        //Grab the General Ledger Account created
        c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];

        //Grab the Dimension 1 record from our Test Data Setup
        c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];

        Decimal amount = 10.0;
        List<c2g__codaJournalLineItem__c> jLineItems = new List<c2g__codaJournalLineItem__c>();
        c2g__codaJournalLineItem__c jLineItem_1 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 1,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = gla1.Id,
            c2g__Value__c = amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_1);

        c2g__codaJournalLineItem__c jLineItem_2 = new c2g__codaJournalLineItem__c(
            c2g__LineNumber__c = 2,
            c2g__Journal__c = journal.Id,
            c2g__LineType__c = 'General Ledger Account',
            c2g__GeneralLedgerAccount__c = gla1.Id,
            c2g__Value__c = -amount,
            c2g__LineDescription__c = 'Test JLA',
            c2g__Dimension1__c = dim1.Id
        );
        jLineItems.add(jLineItem_2);
        insert jLineItems;

        List<c2g__codaJournal__c> journalList = new List<c2g__codaJournal__c>();
        journalList.add(journal);

         c2g__codaJournal__c unapprovedJournal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false
        );
        insert unapprovedJournal;
        journalList.add(unapprovedJournal);
        
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(journalList);
        stdController.setSelected(journalList);
        JournalApprovalValidationListController journalController = new JournalApprovalValidationListController(stdController);

        }
        
        Test.startTest();

        //Create the users we need for our tests
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User approver = testUtilities.CreateNewUser(p, true);
        approver.LastName = 'Approver';
        
        Util.ByPassAllTriggers = true;
        update approver;
		Util.ByPassAllTriggers = false;
        
        System.runAs(approver){

        //Need to give the testing user the custom permissions to Approve & Post Journal and also mark as a Royall process user
        PermissionSet customPermission1 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Post'];                              

        List<PermissionSetAssignment> allPermissionSetAssignments = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPS1 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission1.Id);
        PermissionSetAssignment assignPS2 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission2.Id);
        PermissionSetAssignment assignPS3 = new PermissionSetAssignment (AssigneeId = User1.Id, PermissionSetId = customPermission3.Id);
        PermissionSetAssignment assignPS4 = new PermissionSetAssignment (AssigneeId = approver.Id, PermissionSetId = customPermission1.Id);
        allPermissionSetAssignments.add(assignPS1);
        allPermissionSetAssignments.add(assignPS2);
        allPermissionSetAssignments.add(assignPS3);
        allPermissionSetAssignments.add(assignPS4);
        insert allPermissionSetAssignments;

        }

        System.runAs(approver) {

            c2g__codaJournal__c journal = [SELECT Id, Name, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test record'];

            journal.Approved__c = true;
            update journal;
            System.assertEquals(true, journal.Approved__c);

        }

        System.runAs(user1){

            List<c2g__codaJournal__c> journal = [SELECT Id, Name, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test record'];

            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(journal);
            JournalApprovalValidationListController journalController = new JournalApprovalValidationListController(stdController);

            journalController.validateApprovalList();

        }

        Test.stopTest();
       
    }
    
    @isTest static void testRoyallScenarios() {

        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

        //Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

        //Insert Custom Setting record to enforce Approval for User1 later
        ffbext__OneTouchSettings__c onetouchsetting1 = new ffbext__OneTouchSettings__c();
        onetouchsetting1.EnableJournalApproval__c = true;
        onetouchsetting1.SetupOwnerId = User1.Id;
        insert onetouchsetting1;

        System.runAs(user1) {

        //Create the Account needed later for Sales Credit Note
        Account testAcc = TestUtilities.CreateNewAccount(true);

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

        c2g__codaJournal__c journal = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test approval'
            );
        insert journal;

        c2g__codaJournal__c journal2 = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test creator posting'
            );
        insert journal2;

        c2g__codaJournal__c journal3 = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test approver posting'
            );
        insert journal3;

        }

        //Create a user for inserting Permission Set Assignments to avoid DML errors
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User poster = testUtilities.CreateNewUser(p, true);
        poster.LastName = 'Poster';
        update poster;

        System.runAs(poster){

        //Need to give the testing user the custom permissions to Approve & Post Journal and also mark as a Royall process user
        PermissionSet customPermission1 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Approve'];

        PermissionSet customPermission2 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Royall FinancialForce Process'];

        PermissionSet customPermission3 = [SELECT Id, Label 
                                          FROM PermissionSet
                                          WHERE Label = 'Journal - Permission to Post'];                              

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

        System.runAs(user2){

        c2g__codaJournal__c journal4 = new c2g__codaJournal__c(
            c2g__Type__c = 'Manual Journal',
            ffgl__DeriveCurrency__c = true,
            ffgl__DerivePeriod__c = true,
            c2g__JournalStatus__c = 'In Progress',
            c2g__JournalDate__c = Date.today(),
            Registered_Date__c = Date.today(),
            Approved__c = false,
            c2g__JournalDescription__c = 'test approval - Royall'
            );
        insert journal4;

        }

        System.runAs(user1){

        c2g__codaJournal__c journal = [SELECT Id, Name, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test approval - Royall'];

        ApexPages.StandardController stdController = new ApexPages.StandardController(journal);
        JournalApprovalValidationController journalController = new JournalApprovalValidationController(stdController);

        //Run the Posting Process before Approval
        journalController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail() == ('This Journal must be approved before it can be posted.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);

        //Mark the record as approved
        journal.Approved__c = True;
        update journal;

        //Run the Posting Process
        journalController.validateApproval();

        isMessageFound = false;

        List<ApexPages.Message> msgs2 = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs2){
                if (msg.getDetail() == ('This Journal cannot be posted by the Approver.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);

        }

        System.runAs(user2){

        c2g__codaJournal__c journal = [SELECT Id, Name, Approved__c, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test creator posting'];

        journal.Approved__c = true;
        update journal;

        }

        System.runAs(user1){

        c2g__codaJournal__c journal = [SELECT Id, Name, Approved__c, c2g__JournalDescription__c FROM c2g__codaJournal__c WHERE c2g__JournalDescription__c = 'test creator posting'];

        ApexPages.StandardController stdController = new ApexPages.StandardController(journal);
        JournalApprovalValidationController journalController = new JournalApprovalValidationController(stdController);

        //Run the Posting Process
        journalController.validateApproval();

        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail() == ('This Journal cannot be posted by the Creator.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);

        }

    }
}