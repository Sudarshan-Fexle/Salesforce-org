/** 
*   Purpose         :   Test class for the lineItemScheduleUpsertController
*
*   Created By      :   Victor Hanson
*
*   Created Date    :   10/24/2014
*
*   Revision Logs   :   V_1.0 - Created
*                       V_1.1 - Modified By - Abhinav Sharma - 12-01-2015 - CR-20141120-8130 - LineItemScheduleUpsertController - 96%
*                       V_1.2 - Modified By - Abhinav Sharma - 13-02-2015 - CR-20150129-8606 - LineItemScheduleUpsertController - 95%
*
**/ 
@isTest(seeAllData=false)
private class Test_LineItemScheduleUpsertController {
    
    static testMethod void testAddLineItemSchedule() {
        
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
        
        Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        insert contractABC;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30));
        insert lISToInsert;
        
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_MassUpsert;
        test.setCurrentPage(pageRef);
        
        //Add Contract ABC Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', contractABC.Id);
        
        // instantiate the controller and set the page
        LineItemScheduleUpsertController controller = new LineItemScheduleUpsertController();
        
        system.assertEquals(3, controller.lineItemWrappers.size());
        
        //add 2 new line items
        controller.numRows = 2;
        controller.addRows();
        
        system.assertEquals(5, controller.lineItemWrappers.size());
        
        for (LineItemScheduleCloneController.LineItemWrapper wrapper : controller.lineItemWrappers) {
            if (wrapper.LineItem.Invoice_Date__c == null) wrapper.LineItem.Invoice_Date__c = system.today();
            wrapper.LineItem.Invoice_Amount__c = 1234;
        }
        controller.save();
        
        //Get all line item schedules from Contract ABC2
        list<Line_Item_Schedule__c> lineItemSchedules = [SELECT Id, Contract__c, Amount__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE Contract__c = :contractABC.Id];
        system.assertEquals(5, lineItemSchedules.size());
        system.assertEquals(1234, lineItemSchedules[0].Invoice_Amount__c);
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteLineItemSchedule() {
        
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
        
        Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        insert contractABC;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30));
        insert lISToInsert;
        
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_MassUpsert;
        test.setCurrentPage(pageRef);
        
        string LISIdsCommaDelim = '';
        for (Line_Item_Schedule__c lis : lISToInsert) {
            LISIdsCommaDelim += lis.Id + ',';
        }
        
        //Add Contract ABC Id param to page URL 
        ApexPages.currentPage().getParameters().put('ids', LISIdsCommaDelim);
        
        // instantiate the controller and set the page
        LineItemScheduleUpsertController controller = new LineItemScheduleUpsertController();
        
        system.assertEquals(3, controller.lineItemWrappers.size());
        
        //de-select the first item, and delete the second two
        controller.lineItemWrappers[0].isSelected = false;
        controller.deleteRows();
        
        //make sure no error was returned
        system.assertEquals(new list<ApexPages.Message>(), ApexPages.getMessages());
        
        //Get all line item schedules from Contract ABC2
        list<Line_Item_Schedule__c> lineItemSchedules = [SELECT Id, Contract__c, Amount__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE Contract__c = :contractABC.Id];
        system.assertEquals(1, lineItemSchedules.size());
        
        Test.stopTest();
    }
    
    static testMethod void testSaveLineItemError() {
        
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
        
        Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
        insert contractABC;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30));
        insert lISToInsert;
        
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_MassUpsert;
        test.setCurrentPage(pageRef);
        
        //Add Contract ABC Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', contractABC.Id);
        
        // instantiate the controller and set the page
        LineItemScheduleUpsertController controller = new LineItemScheduleUpsertController();
        
        //set the first invoice amount to null and save, which should return an error
        controller.lineItemWrappers[0].LineItem.Invoice_Amount__c = null;
        controller.save();
        
        //make sure no error was returned
        system.assertEquals(true, controller.hasErrors);
        system.assertNotEquals(new list<ApexPages.Message>(), ApexPages.getMessages());
        
        Test.stopTest();
    }
    
    static testMethod void testLineItemScheduleForBillingSchedule() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers to easily create the test data 
        Util.byPassAllTriggers = true;
        
        //create the account and contact sample data
        Account institution = testUtilities.CreateNewAccount(true);
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
        insert invoiceBillingSchedule;
        
        //insert the program test data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'TestProgram_2', Program_Acronym__c = 'CCC');
        Program__c program_2 = new Program__c(Name = 'TestProgram_3');
        programs.add(program_1);
        programs.add(program_2);
        insert programs;
        
        //insert the Main contact record
        Contact mainContact = new Contact(LastName = 'TestLastName_2', AccountId = institution.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert mainContact;
        
        //List of contract records
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Contract
        Contract__c contractABC_1 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), 
                                                   End__c = Date.today(), Historical_Linker__c = '111111',
                                                   Year__c = '2011', Program__c = programs[0].Id, 
                                                   Join_Date__c = Date.today(),  Invoice_Contact__c = mainContact.Id,
                                                   Main_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, 
                                                   Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
                                                   
        Contract__c contractABC_2 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), 
                                                   End__c = Date.today(), Historical_Linker__c = '111112',
                                                   Year__c = '2011', Program__c = programs[1].Id, 
                                                   Join_Date__c = Date.today(),  Invoice_Contact__c = mainContact.Id,
                                                   Main_Contact__c = mainContact.Id, 
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, 
                                                   Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
                                                   
        //Populating list with records
        contracts.add(contractABC_1);
        contracts.add(contractABC_2);
        insert contracts;
                         
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contracts[0].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 10));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contracts[1].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test2', Invoice_Date__c = Date.today().addDays(1), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 20));
        lISToInsert.add(new Line_Item_Schedule__c(Contract__c = contracts[0].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test3', Invoice_Date__c = Date.today().addDays(2), Invoice_Comment__c = 'Test1', 
                                                  Amount__c = 30));
        insert lISToInsert;
        
        //start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.LineItemSchedule_MassUpsert;
        test.setCurrentPage(pageRef);
        
        //Add invoiceBillingSchedule Id param to page URL 
        ApexPages.currentPage().getParameters().put('id', invoiceBillingSchedule.Id);
        
        // instantiate the controller and set the page
        LineItemScheduleUpsertController controller = new LineItemScheduleUpsertController();
        system.assertEquals(3, controller.lineItemWrappers.size());
        
        //Applying filters
        controller.filterInstance.historicalLinker = '111111';
        controller.lItemSchedule.Invoice_Date__c = null;
        controller.applyFilters();
        
        controller.filterInstance.historicalLinker = '111111';
        controller.lItemSchedule.Invoice_Date__c = System.today();
        controller.applyFilters();
        
        controller.lItemSchedule.Invoice_Date__c = System.today();
        controller.filterInstance.historicalLinker = '';
        controller.applyFilters();
        System.assertEquals(1, controller.lineItemWrappers.size());
        
        controller.lItemSchedule.Invoice_Date__c = null;
        controller.filterInstance.historicalLinker = '';
        controller.applyFilters();
        System.assertEquals(3, controller.lineItemWrappers.size());
        
        controller.lISchedule.Type__c = '';
        controller.lISchedule.Invoice_Comment__c = 'Test';
        controller.lISchedule.Line_Item_Comment__c = 'blank';
        controller.lISchedule.Line_Item_Comment_2__c = 'Testing';
        controller.updateValuesOnLineItems();
        System.assertEquals(3, controller.lineItemWrappers.size());
        System.assertEquals('Test', controller.lineItemWrappers[0].lineItem.Invoice_Comment__c);
        System.assertEquals('', controller.lineItemWrappers[0].lineItem.Line_Item_Comment__c);
        System.assertEquals('Testing', controller.lineItemWrappers[0].lineItem.Line_Item_Comment_2__c);
        System.assertEquals('Test1', controller.lineItemWrappers[0].lineItem.Type__c);
        System.assertEquals('Test', controller.lineItemWrappers[1].lineItem.Invoice_Comment__c);
        System.assertEquals('', controller.lineItemWrappers[1].lineItem.Line_Item_Comment__c);
        System.assertEquals('Testing', controller.lineItemWrappers[1].lineItem.Line_Item_Comment_2__c);
        System.assertEquals('Test2', controller.lineItemWrappers[1].lineItem.Type__c);
        System.assertEquals('Test', controller.lineItemWrappers[2].lineItem.Invoice_Comment__c);
        System.assertEquals('', controller.lineItemWrappers[2].lineItem.Line_Item_Comment__c);
        System.assertEquals('Testing', controller.lineItemWrappers[2].lineItem.Line_Item_Comment_2__c);
        System.assertEquals('Test3', controller.lineItemWrappers[2].lineItem.Type__c);
        
        controller.hLinker = '111111';
        controller.fetchProgramAcronyms();
        
        controller.hLinker = '111112';
        controller.fetchProgramAcronyms();
        
        controller.lISchedule.Type__c = 'test';
        controller.updateValuesOnLineItems();
        controller.lISchedule.Line_Item_Comment__c = 'Test';
        controller.updateValuesOnLineItems();
        controller.lISchedule.Line_Item_Comment_2__c = 'blank';
        controller.updateValuesOnLineItems();
        controller.lISchedule.Invoice_Date__c = System.today();
        controller.updateValuesOnLineItems();
        controller.hLinker = '';
        controller.fetchProgramAcronyms();
        controller.updatingWrapperWithMapValues();
        
        controller.next();
        controller.previous();
        controller.last();
        controller.first();
        Integer tPages = controller.totalPages;
        Integer pNum = controller.pageNumber;
        Boolean hasNextBol = controller.hasNext;
        Boolean hasPreviousBol = controller.hasPrevious;
        controller.populateStandardSetControllerWithFilters('', null);
        controller.lineItemWrappers = null;
        try {
            controller.save();
        } catch(Exception ex) {}
        try {
            controller.deleteRows();
        } catch(Exception e) {}
        controller.numRows = 1000;
        try {
            controller.addRows();
        } catch(Exception es) {}
        
        //Stop Test here
        Test.stopTest();
    }
}