/**
    Desription      :   This class is a test class for TriggerLineItemSchedule 
  
    Created By      :   Shalu Sharma 
  
    Created Date    :   08/16/2021
  
    Revision Logs   :   Added By - Shalu Sharma - CR-20210528-15187
                    :   Modified By - CR-20211012-15511 - Update test class for increase code coverage
**/ 
@isTest(SeeAllData=true)
private class Test_TriggerLineItemSchedule 
{
    static testMethod void testTriggerWithNoInvoice() 
    {
        String randomNumber  = String.valueOf(Integer.valueof((Math.random() * 1000)));
        Test.startTest();
        //Create Account
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert a;
        
        //Create Contact
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test', Email = 'test'+randomNumber+'@gmail.com', Phone = '123456', Title = 'Test Contact');
        insert con; 

        //Create Program
        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
 
         //Create Contract ABC
        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;
        
        //Create the Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert invoiceBillingSchedule;
        
        //Update the billing invoice record id
        c.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;                                   
        update c;
        
        Util.BypassAllTriggers = false;
        
        //Insert Line Item Schedule
        List<Line_Item_Schedule__c> lineItemSchedules = new List<Line_Item_Schedule__c>();
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', Amount__c = 20));
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today()+1, Invoice_Comment__c = 'Test', Amount__c = 100));
        insert lineItemSchedules;
        
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Allow_Timecards_Without_Assignment__c = false,
            pse__Allow_Expenses_Without_Assignment__c = false,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            Billable_Expense_Types_Apply__c = true
        );
        insert project;
        
        pse__Milestone__c milestone = new pse__Milestone__c(
            Name = 'Test Milestone',
            pse__Milestone_Amount__c = 1000.0,
            pse__Target_Date__c = project.pse__End_Date__c,
            pse__Actual_Date__c = project.pse__End_Date__c,
            pse__Project__c = project.Id,
            pse__Approved__c = true,
            pse__Status__c = 'Approved',
            pse__Include_In_Financials__c = true,
            pse__Approved_for_Billing__c = true,
            Line_Item_Schedule__c = lineItemSchedules[1].Id
        );
        insert milestone;
        
         pse__Miscellaneous_Adjustment__c adminFeeMA = createAdminFeeMA(project, lineItemSchedules[1]);
        
        try{
        delete lineItemSchedules;
        }
        catch(Exception ex)
        {
              system.assertEquals(true, ex.getMessage().contains('This Line Item Schedule has a relationship with a Miscellaneous Adjustment used for Admin Fees and ' +
                                'cannot be deleted. To credit Admin Fees back to the customer, manually create a Miscellaneous Adjustment ' +
                                'of type Ready To Bill Revenue with a negative dollar amount on the Project and generate and release ' +
                                'a Billing Event. This will create another LIS with a negative dollar amount.'));

        }
       
        
        Test.stopTest();
        
       
    }
    
    static testMethod void testTriggerWithNoInvoice1() 
    { 
        String randomNumber  = String.valueOf(Integer.valueof((Math.random() * 1000)));
        Test.startTest();
        //Create Account
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert a;
        
        //Create Contact
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test', Email = 'test'+randomNumber+'@gmail.com', Phone = '123456', Title = 'Test Contact');
        insert con; 

        //Create Program
        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
 
         //Create Contract ABC
        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;
        
        //Create the Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert invoiceBillingSchedule;
        
        //Update the billing invoice record id
        c.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;                                   
        update c;
        
        Util.BypassAllTriggers = false;
        
        //Insert Line Item Schedule
        List<Line_Item_Schedule__c> lineItemSchedules = new List<Line_Item_Schedule__c>();
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,Invoiced__c = true,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', Amount__c = 20));
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today()+1, Invoice_Comment__c = 'Test', Amount__c = 100));
        insert lineItemSchedules;
        
        try{
        delete lineItemSchedules;
        }
        catch(Exception ex)
        {
            system.assertEquals(true, ex.getMessage().contains( 'A Line Item Schedule that has been invoiced cannot be deleted'));

        }
        

        Test.stopTest();
    }
    
    //Added By - Shalu Sharma - CR-20210528-15187 - Added new "test_populateLineItemScheduleTotalOnContractABC" method
    static testMethod void test_populateLineItemScheduleTotalOnContractABC()
    {
        Util.BypassAllTriggers = true;
        String randomNumber  = String.valueOf(Integer.valueof((Math.random() * 1000)));
    	
        //Create Account
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert a;
        
        //Create Contact
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test', Email = 'test'+randomNumber+'@gmail.com', Phone = '123456', Title = 'Test Contact');
        insert con; 

        //Create Program
        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
 
         //Create Contract ABC
        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;
        
        //Create the Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert invoiceBillingSchedule;
        
        //Update the billing invoice record id
        c.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;                                   
        update c;
        
        Util.BypassAllTriggers = false;
        
        //Insert Line Item Schedule
        List<Line_Item_Schedule__c> lineItemSchedules = new List<Line_Item_Schedule__c>();
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', Amount__c = 20));
        lineItemSchedules.add(new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                         Type__c = 'Test', Invoice_Date__c = Date.today()+1, Invoice_Comment__c = 'Test', Amount__c = 100));
        insert lineItemSchedules;
        
        List<Contract__c> contracts = [SELECT Id, Line_Item_Schedule_Total__c FROM Contract__c WHERE Id =: c.Id];
        System.assertEquals(120, contracts[0].Line_Item_Schedule_Total__c);
        
        Test.startTest();
        
        lineItemSchedules[0].Amount__c = 40;
        update lineItemSchedules;
        
        List<Contract__c> updatedContracts = [SELECT Id, Line_Item_Schedule_Total__c FROM Contract__c WHERE Id =: c.Id];
        System.assertEquals(140, updatedContracts[0].Line_Item_Schedule_Total__c);
        
        Test.stopTest();    
    }
    
    static Line_Item_Schedule__c CreateNewLineItemSchedule(boolean withInvoice) 
    {
        // greate a general ledger account for the c2g__CODAAccountsReceivableControl__c field on acct
        c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType balanceSheet = c2g.CODAAPIGeneralLedgerAccountTypes_3_0.enumType.BalanceSheet;
        c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount glAcctStub = new c2g.CODAAPIGeneralLedgerAccountTypes_3_0.GeneralLedgerAccount();
        glAcctStub.BalanceSheet1 = '1';
        //glAcctStub.CurrencyISOCode = 'USD';
        glAcctStub.Name = 'vicTestGeneralLedger1';
        glAcctStub.ReportingCode = '123abc1zz';
        glAcctStub.TypeRef = balanceSheet;
        c2g.CODAAPICommon.Reference glAcctRef = c2g.CODAAPIGeneralLedgerAccount_3_0.CreateGeneralLedgerAccount(null, glAcctStub);
        c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c();
        glAccount.c2g__ExternalId__c = glAcctRef.Id;
        glAccount.c2g__ReportingCode__c = '123abc1zzz';
        glAccount.c2g__Type__c = 'Balance Sheet';
        insert glAccount;
    
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc', c2g__CODAAccountsReceivableControl__c = glAccount.Id);
        //a.RecordTypeId = listRecordType[0].Id;
        insert a;
        
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test');
        insert con;

        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
 
        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;
        
        // test sales invoice
        c2g.CODAAPIInvoiceTypes_4_0.Invoice salesinvoice = new c2g.CODAAPIInvoiceTypes_4_0.Invoice(); 
        //Set the fields for the invoice 
        salesinvoice.Account = new c2g.CODAAPICommon.Reference(); 
        salesinvoice.GeneralLedgerAccount = glAcctRef;
        salesinvoice.Account.Id = a.Id; 
        salesinvoice.CustomerReference = 'Sale #1'; 
        salesinvoice.InvoiceCurrency = new c2g.CODAAPICommon.Reference(); 
        salesinvoice.InvoiceCurrency.Name = 'USD'; 
        salesinvoice.InvoiceStatus = c2g.CODAAPIInvoiceTypes_4_0.enumInvoiceStatus.InProgress; 
        salesinvoice.InvoiceDate = System.now().date(); 
        salesinvoice.DueDate = System.now().date() + 30; 
        salesinvoice.InvoiceDescription = 'Widget order for Test Company'; 
        salesinvoice.UsePartPeriods = false; 
        salesinvoice.PrintedText1AllowEdit = false; 
        salesinvoice.PrintedText2AllowEdit = false; 
        salesinvoice.PrintedText3AllowEdit = false; 
        salesinvoice.PrintedText4AllowEdit = false; 
        salesinvoice.PrintedText5AllowEdit = false;
        
        //insert the  Invoice Billing record
        Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert invoiceBillingSchedule;
        
        //update the billing invoice record id
        c.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;                                   
        update c;
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        Line_Item_Schedule__c lIS = new Line_Item_Schedule__c(Contract__c = c.Id,
                                                              Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id,
                                                              Type__c = 'Test',
                                                              Invoice_Date__c = Date.today(),
                                                              Invoice_Comment__c = 'Test',
                                                              Amount__c = 20);
        insert lIS;
    
        if(withInvoice) {
            //Create the Sales Invoice via the API 
            c2g.CODAAPICommon.Reference ref = c2g.CODAAPISalesInvoice_4_0.CreateInvoice(null, salesinvoice);
            lIS.Sales_Invoice__c = ref.Id;
            update lIS;
        }
        
        return lIS;
    }
    
     private static pse__Miscellaneous_Adjustment__c createAdminFeeMA(pse__Proj__c project, Line_Item_Schedule__c lis) {
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c(
            Name = 'Admin Fee',
            pse__Effective_Date__c = Date.today(),
            pse__Amount__c = 100.0,
            pse__Transaction_Category__c = 'Ready-to-Bill Revenue',
            pse__Status__c = 'Approved',
            pse__Approved__c = true,
            pse__Include_In_Financials__c = true,
            pse__Project__c = project.Id,
            Line_Item_Schedule__c = lis.Id
        );
        insert miscAdj;
        return miscAdj;
    }
 
    //CR-20211012-15511 - Created Method
    static testMethod void testMethod1(){
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        Invoice_Billing_Schedule__c invoiceBillingSchedule = [Select Id From Invoice_Billing_Schedule__c Limit 1];
        System.assert(invoiceBillingSchedule.Id != null);
        
        SBQQ__Subscription__c programSub = [Select Id, Shadow_Contract_ABC__c From SBQQ__Subscription__c Limit 1];
        System.assert(programSub.Id != null);
        
        
        //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
        list<Line_Item_Schedule__c> lISToInsert = new list<Line_Item_Schedule__c>();
        lISToInsert.add(new Line_Item_Schedule__c(Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                  Type__c = 'Test1', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test1', 
                                                  Program_Subscription__c = programSub.Id,
                                                  Amount__c = 10,
                                                  Invoiced__c = true
                                                 ));
        
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        insert lISToInsert;
        
		Line_Item_Schedule__c lis = [Select Id, Contract__c, Program_Subscription__r.Shadow_Contract_ABC__c From Line_Item_Schedule__c Where ID = :lISToInsert[0].Id];
		System.assert(lis.Id != null);
		System.assertEquals(lis.Program_Subscription__r.Shadow_Contract_ABC__c, lis.Contract__c); 
        
        Test.stopTest();
    }   
    
}