@isTest(SeeAllData = true)
private class Test_SalesCreditAndInvoiceTriggers {

    static testMethod void SalesCreditAndInvoiceTriggerTest() {/*
        try {
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
                insert a;
                
                Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test');
                insert con;
        
                Program__c p = new Program__c(Name = 'TestProgram');
                insert p;
         
                Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
                Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
                Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
                insert c;
        
                Product2 prod = [SELECT Id, Name FROM Product2 Limit 1]; 
                prod.c2g__CODASalesRevenueAccount__c = glAccount.Id;
                update prod;
                
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
                //salesinvoice.ContractABC__c = c.Id;
                
                //Set up the Sales Invoice to receive line items
                salesinvoice.LineItems = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItems();
                salesinvoice.LineItems.LineItemList = new List<c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem>(); 
                //Create the line item
                c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem salesinvoiceitem = new c2g.CODAAPIInvoiceLineItemTypes_4_0.InvoiceLineItem();
                salesinvoiceitem.Product = new c2g.CODAAPICommon.Reference(); 
                salesinvoiceitem.Product.Id = prod.Id; 
                salesinvoiceitem.UnitPrice = 200; 
                salesinvoiceitem.Quantity = 1; 
                salesinvoiceitem.LineDescription = '1 $200 Widget'; 
                salesinvoiceitem.TaxValue1 = 0; 
                salesinvoiceitem.UsePartPeriods = false; 
                
                //Add the line item to the Sales Invoice
                //salesinvoice.LineItems.LineItemList.add(salesinvoicelineitem); 
                salesinvoice.LineItems.LineItemList.add(salesinvoiceitem); 
        
                // create a 2nd invoice to test the rollup
                c2g__codaInvoice__c salesinvoice2 = new c2g__codaInvoice__c(c2g__Account__c = a.Id, ContractABC__c = c.Id);
                try {
                    insert salesinvoice2;
                } catch(Exception e){}
        
                //c2g__codaInvoiceLineItem__c salesinvoiceitem2 = new c2g__codaInvoiceLineItem__c(c2g__Invoice__c = salesinvoice2.Id, c2g__Product__c = prod.Id, c2g__UnitPrice__c = 10, ffbilling__DeriveUnitPriceFromProduct__c = false);
                c2g__codaInvoiceLineItem__c salesinvoiceitem2 = new c2g__codaInvoiceLineItem__c(ffbilling__DeriveUnitPriceFromProduct__c = false, c2g__Invoice__c = salesinvoice2.Id, c2g__Product__c = prod.Id, c2g__UnitPrice__c = 10);
            
                try {
                    insert salesinvoiceitem2;
                } catch(Exception e){ }
                c2g.CODAAPICommon.Reference ref;
                //Create the Sales Invoice via the API 
                try {
                    ref = c2g.CODAAPISalesInvoice_4_0.CreateInvoice(null, salesinvoice); 
                    
                    c2g__codaInvoice__c delinv = [select Id from c2g__codaInvoice__c where Id = :ref.Id]; 
                    delinv.ContractABC__c = c.Id;
                    update delinv;
                } catch(Exception e) {}
        
                // test credit note
                c2g__codaCreditNote__c cn = new c2g__codaCreditNote__c(c2g__Account__c = a.Id, ContractABC__c = c.Id);
                try {
                    insert cn;
                    c2g.CODAAPISalesInvoice_7_0.PostInvoice(null, ref);
                } catch(Exception e) {}
                
                /*
                // go to the SalesInvoicePost VF page to post the invoice which will create a transaction record
                try {
                PageReference pageRef = Page.ffbilling__salesinvoicepost;
                pageRef.getParameters().put('id', delinv.Id);
                Test.setCurrentPage(pageRef);
                } catch(Exception e) {}
        
            //test.setCurrentPageReference(pageRef);
                //ApexPages.StandardController stdCon = new ApexPages.standardController(delinv);
                //ffbilling.SalesInvoiceController controller = new ffbilling.SalesInvoiceController(stdCon);
                //controller.post();*/
                
                
        /*      // test transaction
                c2g__codaTransaction__c t = new c2g__codaTransaction__c(c2g__Account__c = a.Id);
                insert t;
        
                salesinvoice2.c2g__Transaction__c = t.Id;
                update salesinvoice2;
        */      
        
        
        //      c2g__codaTransactionLineItem__c tli = new c2g__codaTransactionLineItem__c(c2g__Transaction__c = t.Id, c2g__DocumentOutstandingValue__c = 101.00);
        //      insert tli;
       // } catch(Exception e) {}
    }
    
    static testMethod void SalesCreditAndInvoiceTriggerTest2() {/*
        try {
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
                insert a;
            
            // test transaction
                c2g__codaTransaction__c t = new c2g__codaTransaction__c(c2g__Account__c = a.Id);
                insert t;
        
        } catch(Exception e) {}*/
    }
}