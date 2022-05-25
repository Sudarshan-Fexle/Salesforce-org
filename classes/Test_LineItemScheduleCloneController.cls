//Modified By - Abhinav Sharma - 05/26/2015 - CR-20140321-4840
//V_1.1 - Modified - Deepak Kumar -Q2C Phase 2 - CR-20170403-10807 - Start here
//V_1.2 - Modified - Deepak Kumar - 07/03/2017 - Q2C
@isTest(seeAllData = false)
private class Test_LineItemScheduleCloneController{
    
    static testMethod void testCloneLineItemSchedule() {
        
        //create the account and contact sample data
        Account institution = testUtilities.CreateNewAccount(true);
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
        insert invoiceBillingSchedule;
        
        //List to hold the record's type 
        List<RecordType> listOfSubscriptionRecordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM LIMIT 1 ];        
        
        //insert the program test data
        Program__c program = new Program__c(Name = 'TestProgram_2');
        insert program;
        
        //insert the Main contact record
        Contact mainContact = new Contact(LastName = 'TestLastName_2', AccountId = institution.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert mainContact;
        
        Contract__c contractABC1 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        Contract__c contractABC2 = new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test2', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2013', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        List<Contract__c> contractABCList = new List<Contract__c> { contractABC1, contractABC2 };
        
        //Insert the contractList
        insert contractABCList;
        
        //get the record type for 2 line item schedule record types
        Id rtId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule').RecordTypeId;
        Id invoicedRTId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule-Invoiced').RecordTypeId;
        
        //create the sales invoice
        c2g__codaInvoice__c salesinvoice = new c2g__codaInvoice__c(c2g__Account__c = institution.Id, ContractABC__c = contractABC2.Id);
        try {
            insert salesinvoice;
        } catch(Exception e){}
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10,
                                                  RecordTypeId = invoicedRTId,
                                                  Invoiced__c = true,
                                                  Sales_Invoice__c = salesinvoice.Id));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20,
                                                  RecordTypeId = invoicedRTId,
                                                  Invoiced__c = true,
                                                  Sales_Invoice__c = salesinvoice.Id));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30,
                                                  RecordTypeId = invoicedRTId,
                                                  Invoiced__c = true,
                                                  Sales_Invoice__c = salesinvoice.Id));
        insert lISToInsert;
       
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_Clone;
        test.setCurrentPage(pageRef);
        
        //Add Contract ABC2 Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', contractABC2.Id);
        
        // instantiate the controller and set the page
        LineItemScheduleCloneController controller = new LineItemScheduleCloneController();
        
        system.assertEquals(1, controller.contractWrappers.size(), 'Only one contract ABC should be in the list of contractWrappers.');
        system.assertEquals(contractABC1.Id, controller.contractWrappers[0].contractId, 'ContractABC1 should be in the list of contractWrappers');
        
        //Attempt to save prior to selecting a contract to clone -- make sure isSuccess is not true
        controller.save();
        system.assertNotEquals(true, controller.isSuccess);
        
        //Modified By - Abhinav Sharma - 05/24/2014 - CR-20140321-4840
        //Select contract whose Line Item Schedules will be cloned
        controller.contractWrappers[0].isSelected = true;
        Double disp = controller.contractWrappers[0].discrepancy;
        
        //verify the total amount is accurate
        controller.recalculateTotals();
        system.assertEquals(60, controller.contractWrappers[0].total);
        
        controller.selectedContractWrappers[0].lineItems[0].lineItem.Amount__c = 500;
        
        //verify the total amount has been updated
        controller.recalculateTotals();
        system.assertEquals(550, controller.contractWrappers[0].total);
        
        controller.save();
        
        //Get all line item schedules from Contract ABC2
        list<Line_Item_Schedule__c> lineItemSchedules = [SELECT Id, Contract__c, Amount__c, Invoice_Amount__c, RecordTypeId, Sales_Invoice__c, Invoiced__c FROM Line_Item_Schedule__c WHERE Contract__c = :contractABC1.Id];
        system.assertEquals(3, lineItemSchedules.size());
        system.assertEquals(500, lineItemSchedules[0].Amount__c);
        system.assertEquals(500, lineItemSchedules[0].Invoice_Amount__c);
        system.assertEquals(rtId, lineItemSchedules[0].RecordTypeId);
        system.assertEquals(null, lineItemSchedules[0].Sales_Invoice__c);
        system.assertEquals(false, lineItemSchedules[0].Invoiced__c);
        
        Test.stopTest();
    }
    
    static testMethod void testCloneToMultipleContracts() {
        
        //create the account and contact sample data
        Account institution = testUtilities.CreateNewAccount(true);
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
        insert invoiceBillingSchedule;
        
        //insert the program test data
        Program__c program = new Program__c(Name = 'TestProgram_2');
        insert program;
        
        //insert the Main contact record
        Contact mainContact = new Contact(LastName = 'TestLastName_2', AccountId = institution.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert mainContact;
        
        Contract__c contractABC1 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                  Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                  Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                  Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        Contract__c contractABC2 = new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test2', Start__c = Date.today(), End__c = Date.today(), 
                                                  Year__c = '2013', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                  Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                  Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        Contract__c contractABC3_noLineItemScheds = new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test2', Start__c = Date.today(), End__c = Date.today(), 
                                                  Year__c = '2013', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                  Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                  Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        List<Contract__c> contractABCList = new List<Contract__c> { contractABC1, contractABC2, contractABC3_noLineItemScheds };
        insert contractABCList;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        Line_Item_Schedule__c LIS1 = new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                               Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                               Amount__c = 10);
        Line_Item_Schedule__c LIS2 = new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                               Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                               Amount__c = 20);
        Line_Item_Schedule__c LIS3 = new Line_Item_Schedule__c(Contract__c = contractABC2.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                               Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                               Amount__c = 30);
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c> { LIS1, LIS2, LIS3 };
        insert lISToInsert;
       
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_Clone;
        test.setCurrentPage(pageRef);
        
        //Add Contract ABC2 Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', contractABC2.Id);
        
        // instantiate the controller and set the page
        LineItemScheduleCloneController controller = new LineItemScheduleCloneController();
        
        system.assertEquals(2, controller.contractWrappers.size(), 'Two contract ABC should be in the list of contractWrappers.');
        
        //select ALL contracts in our list
        controller.selectAllType = 'CONTRACTS';
        controller.selectValue = true;
        controller.toggleSelected();
        //verify all available contracts have been selected
        for (LineItemScheduleCloneController.ContractWrapper cWrapper : controller.contractWrappers) {
            system.assertEquals(true, cWrapper.isSelected);
        }
        
        //unselect ALL contracts in our list
        controller.selectAllType = 'CONTRACTS';
        controller.selectValue = false;
        controller.toggleSelected();
        //verify all available contracts have been selected
        for (LineItemScheduleCloneController.ContractWrapper cWrapper : controller.contractWrappers) {
            system.assertEquals(false, cWrapper.isSelected);
        }
        
        //reselect all contracts
        controller.selectAllType = 'CONTRACTS';
        controller.selectValue = true;
        controller.toggleSelected();
        
        //verify all line items are selected by default
        for (LineItemScheduleCloneController.ContractWrapper cWrapper : controller.selectedContractWrappers) {
            for (LineItemScheduleCloneController.LineItemWrapper lineItemWrapper : cWrapper.lineItems) {
                system.assertEquals(true, lineItemWrapper.isSelected);
            }
        }
        
        //unselect all line items
        controller.selectAllType = 'LINEITEMS';
        controller.selectValue = false;
        controller.toggleSelected();
        
        //verify all line items are no longer selected
        for (LineItemScheduleCloneController.ContractWrapper cWrapper : controller.selectedContractWrappers) {
            for (LineItemScheduleCloneController.LineItemWrapper lineItemWrapper : cWrapper.lineItems) {
                system.assertEquals(false, lineItemWrapper.isSelected);
            }
        }
        
        //select all line items
        controller.selectAllType = 'LINEITEMS';
        controller.selectValue = true;
        controller.toggleSelected();
        
        //verify all line items are no longer selected
        for (LineItemScheduleCloneController.ContractWrapper cWrapper : controller.selectedContractWrappers) {
            for (LineItemScheduleCloneController.LineItemWrapper lineItemWrapper : cWrapper.lineItems) {
                system.assertEquals(true, lineItemWrapper.isSelected);
            }
        }
        
        //unselect the middle line item schedule so it's not cloned
        controller.selectAllType = LIS2.Id;
        controller.selectValue = false;
        controller.toggleSelected();
        
        controller.save();
        
        //Get all line item schedules from Contract ABC2
        list<Line_Item_Schedule__c> lineItemSchedules = [SELECT Id, Contract__c, Amount__c FROM Line_Item_Schedule__c WHERE Contract__c = :contractABC1.Id];
        system.assertEquals(2, lineItemSchedules.size());
        
        Test.stopTest();
    }
    
    //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2 - CR-20170403-10807 - Start here
    static testMethod void testCloneLineItemScheduleForSubscriptionCase() {
        
        //create the account and contact sample data
        Account accountTest = testUtilities.CreateNewAccount(true);
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = accountTest.Id);
        insert invoiceBillingSchedule;
         
        //List to hold the record's type 
        List<RecordType> listOfSubscriptionRecordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM LIMIT 1 ];        
        
        //insert the program test data
        Program__c program = new Program__c(Name = 'TestProgram_2');
        insert program;
        
        //insert the Main contact record
        Contact mainContact = new Contact(LastName = 'TestLastName_2', AccountId = accountTest.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert mainContact;
        
        System.debug('Inserted contact List' + mainContact);
        System.debug('Inserted invoiceBillingSchedule List' + invoiceBillingSchedule);
        System.debug('Inserted program List' + program);
        System.debug('Inserted accountTest List' + accountTest);
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //List of Contract ABC
        List<Contract__C> contractABCList = new List<contract__C>();
    
        //Add record to list 
        contractABCList.add( new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test2', Start__c = Date.today(), End__c = Date.today(), 
                                                       Year__c = '2013', Join_Date__c = Date.today(),  
                                                       Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                       Status__c = Constants.STATUS_ATL, Payer_Account__c = accountTest.Id, Record_Source__c = 'Shadow',
                                                       Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id));
        contractABCList.add( new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test3', Start__c = Date.today(), End__c = Date.today(), 
                                                       Year__c = '2014', Join_Date__c = Date.today(),  
                                                       Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                       Status__c = Constants.STATUS_ATL, Payer_Account__c = accountTest.Id, Record_Source__c = 'Shadow',
                                                       Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id));
    
        //Insert the contractList
        insert contractABCList;
        
        //List to hold subscription  
        List<SBQQ__Subscription__c> listSubscription = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        listSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, RecordTypeId = listOfSubscriptionRecordTypes[0].Id,
                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 5,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id,
                                                    Invoice_Contact__c = mainContact.Id, Shadow_Contract_ABC__c = contractABCList[0].Id));
                                                    
        listSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 10, RecordTypeId = listOfSubscriptionRecordTypes[0].Id,
                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 6,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Pending', Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id,
                                                    Invoice_Contact__c = mainContact.Id, Shadow_Contract_ABC__c = contractABCList[1].Id));                                            
        //Insert the subscription record list 
        //insert listSubscription;
        
        //Enable the trigger 
        Util.byPassAllTriggers = false;
        
        //get the record type for 2 line item schedule record types
        Id rtId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule').RecordTypeId;
        Id invoicedRTId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule-Invoiced').RecordTypeId;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        /*list<Line_Item_Schedule__c> listOfLIS = new list<Line_Item_Schedule__c>();
        listOfLIS.add(new Line_Item_Schedule__c(Program_Subscription__c = listSubscription[0].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10,
                                                  RecordTypeId = rtId,
                                                  Invoiced__c = true, Contract__c = contractABCList[0].Id));
        listOfLIS.add(new Line_Item_Schedule__c(Program_Subscription__c = listSubscription[1].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20,
                                                  RecordTypeId = rtId,
                                                  Invoiced__c = true, Contract__c = contractABCList[1].Id));
        listOfLIS.add(new Line_Item_Schedule__c(Program_Subscription__c = listSubscription[1].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30,
                                                  RecordTypeId = invoicedRTId,
                                                  Invoiced__c = true, Contract__c = contractABCList[1].Id));*/
        
        //Insert the listOfLIS of Line Item Schedule record
        //insert listOfLIS;
       
        //start test from here
        Test.startTest();
        
        // set the page reference
        /*PageReference pageRef = Page.LineItemSchedule_Clone;
        test.setCurrentPage(pageRef);
        
        //Add Subscription Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', listSubscription[0].Id);
        
        //Instantiate the controller and set the page
        LineItemScheduleCloneController controller = new LineItemScheduleCloneController();
        
        //system.assertEquals(listSubscription[0].Id, controller.contractWrappers[0].proSubId, 'Subscription should be in the list of contractWrappers');
        
        //Attempt to save prior to selecting a contract to clone -- make sure isSuccess is not true
        controller.save();
        system.assertNotEquals(true, controller.isSuccess); */
        
        Test.stopTest();
        
        //Method Calling
        //Boolean isError = controller.hasErrors;
    }
}