/**
    * Purpose		: Test class for InvoiceTriggerHelper
    *
    * Create By		: Abhinav Sharma
    *
    * Created Date	: 06/12/2020
    *
    * Revision Log	: V_1.0 - Created - Mahendra Swanakar
    *
    * Coverage		: V_1.0 - 84%
    *
**/
@isTest(seeAllData = false)
private class Test_InvoiceTriggerHelper
{
    @testSetup static void setup() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Saweda';
        user1.phone = '3456787661';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
        System.runAs(user1) {
            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
        
            List<Contact> contact = new List<Contact>();
            contact.add(new Contact(LastName = 'TestContact1', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            contact.add(new Contact(LastName = 'TestContact2', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            insert contact;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            
            
            Program__c prog = new Program__c(Name = 'TestProgram');
            insert prog;
            
            List<Membership__c> memberships = new List<Membership__c>();
            memberships.add(new Membership__c(Account_Name__c = testAcc.Id, Program__c = prog.Id));
            memberships.add(new Membership__c(Account_Name__c = testAcc.Id, Program__c = prog.Id));
            
            insert memberships;
            
            Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = testAcc.Id, Status__c = 'ATL', 
                                            Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
                                            Main_Contact__c = contact[0].Id, Invoice_Contact__c = contact[0].Id, Program__c = prog.Id);
            insert c;
            
              SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
            insert programSubscription;
            
          
            //Query for our currency from our setup data
            c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' Limit 1];

            c2g__codaCreditNote__c salesCredNote = new c2g__codaCreditNote__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__CreditNoteCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__CreditNoteDate__c = System.Today(),
                c2g__CreditNoteStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                Program_Subscription__c = programSubscription.id,
                ffbext__Approved__c = false
            );
            
            insert salesCredNote;
            //Create our list needed for the tests
            List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();
            
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(c2g__Account__c = testAcc.Id, c2g__DueDate__c = System.today(), c2g__InvoiceDate__c = System.Today(),
                                                                      c2g__InvoiceStatus__c = 'In Progress', c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 1',
                                                                      ContractABC__c = c.Id,Invoice_Contact__c= contact[0].Id, Credit_Manager__c = user1.Id);
            
            //Create our second test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(c2g__Account__c = testAcc.Id,c2g__DueDate__c = System.today(),c2g__InvoiceDate__c = System.Today(),c2g__InvoiceStatus__c = 'In Progress',
                                                                        c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 2',Credit_Manager__c = user1.Id);
            
            salesInvoiceList.add(salesInvoice);
            salesInvoiceList.add(salesInvoice2);
             Util.BypassAllTriggers = false;
            insert salesInvoiceList;

            
        }
        
    }
    
     @isTest static void testSalesInvoicePositiveUseCase() {
        
        Test.startTest();
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        System.runAs(user1) {
            
           //Sales Invoice record we'll work with
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id,Name,c2g__InvoiceDescription__c,Credit_Manager__c,Invoice_Contact__c FROM c2g__codaInvoice__c];
           
            
            // Creating Billing Schedule Periods records
            List<Billing_Schedule_Period__c> billingSchedulePeriods = new List<Billing_Schedule_Period__c>();
            billingSchedulePeriods.add(new Billing_Schedule_Period__c(Installment__c = 1,Invoice_Sent__c = FALSE,Sales_Invoice__c = salesInvoiceList[0].Id));
            insert billingSchedulePeriods;
            
            salesInvoiceList[0].Email_Status__c = 'Emailed' ;
            update salesInvoiceList[0];
        }
         test.stopTest();
     }
    
    @isTest static void test_rollupAmountCreditedTotal(){
        Test.startTest();
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        System.runAs(user1) {
            List<Program__c> programs = new List<Program__c>();
            
            //Add Program Record in list
            programs.add(TestUtilities.CreateNewProgram(true));
            
            //List to hold Institution records
            List<Account> accounts = new List<Account>();
            
            accounts.add(new Account(Name = 'Test AAccount', Status__c = 'Active' ));
            accounts.add(new Account(Name = 'Test BAccount', Status__c = 'Active' ));
            
            //Insert
            insert accounts;
            
            List<Membership__c> memberships = new List<Membership__c>();
            memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
            memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
            
            insert memberships;
            
            SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
            insert programSubscription;
            
            //Grab the Product which is created as part of the Program creation process
            Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];
            
            //Query for our currency from our setup data
            c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' Limit 1];

            c2g__codaCreditNote__c salesCredNote = new c2g__codaCreditNote__c(
                c2g__Account__c = accounts[0].Id,
                c2g__DueDate__c = System.today(),
                c2g__CreditNoteCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__CreditNoteDate__c = System.Today(),
                c2g__CreditNoteStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                Program_Subscription__c = programSubscription.id,
                ffbext__Approved__c = false
            );
            
            insert salesCredNote;
            
            List<c2g__codaCreditNoteLineItem__c> salesCredNoteLineItems = new List<c2g__codaCreditNoteLineItem__c>();
            c2g__codaCreditNoteLineItem__c salesCredNoteLineItems1 = new c2g__codaCreditNoteLineItem__c (
                c2g__CreditNote__c = salesCredNote.Id,
                c2g__UnitPrice__c = 50.00,
                c2g__Quantity__c = 1,
                c2g__DeriveTaxRateFromCode__c = True,
                c2g__DeriveLineNumber__c = True,
                c2g__Product__c = product1.Id          
                );
            c2g__codaCreditNoteLineItem__c salesCredNoteLineItems2 = new c2g__codaCreditNoteLineItem__c (
                c2g__CreditNote__c = salesCredNote.Id,
                c2g__UnitPrice__c = 50.00,
                c2g__Quantity__c = 1,
                c2g__DeriveTaxRateFromCode__c = True,
                c2g__DeriveLineNumber__c = True,
                c2g__Product__c = product1.Id               
                );
            salesCredNoteLineItems.add(salesCredNoteLineItems1);
            salesCredNoteLineItems.add(salesCredNoteLineItems2);
            insert salesCredNoteLineItems;
            
            SBQQ__Subscription__c programSubscription1 = TestUtilities.createNewSubscription(memberships[0].Id, false);
            insert programSubscription1;
            
            salesCredNote.Program_Subscription__c = programSubscription.id;
            update salesCredNote;
        }
    }
    
    @isTest static void test_rollupInvoiceTotal(){
        Test.startTest();
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        System.runAs(user1) {
            
            List<Program__c> programs = new List<Program__c>();
            
            //Add Program Record in list
            programs.add(TestUtilities.CreateNewProgram(true));
            
            //List to hold Institution records
            List<Account> accounts = new List<Account>();
            
            accounts.add(new Account(Name = 'Test AAccount', Status__c = 'Active' ));
            accounts.add(new Account(Name = 'Test BAccount', Status__c = 'Active' ));
            
            //Insert
            insert accounts;
            
            List<Membership__c> memberships = new List<Membership__c>();
            memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
            memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
            
            insert memberships;
            
            SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
            insert programSubscription; 
            
            long l = (long) (Math.random() * 10000000.0);
            String rCode = String.valueOf(l);
            
            c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c(
                Name = rCode + ' - Test GLA',
                c2g__ReportingCode__c = rCode,
                c2g__Type__c = 'Balance Sheet'
            );
            insert glAccount;
            
            //Grab the Product which is created as part of the Program creation process
            Product2 product = new Product2(
                Name = 'Test Product',
                pse__IsServicesProduct__c = true,
                c2g__CODASalesRevenueAccount__c = glAccount.Id
            );
            insert product;
           
            
            
            //Create our list needed for the tests
            List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();
            
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(c2g__Account__c = accounts[0].Id, c2g__DueDate__c = System.today(), c2g__InvoiceDate__c = System.Today(),
                                                                      c2g__InvoiceStatus__c = 'In Progress', c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 1',
                                                                      Credit_Manager__c = user1.Id,Program_Subscription__c= programSubscription.id);
            
            //Create our second test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(c2g__Account__c = accounts[0].Id,c2g__DueDate__c = System.today(),c2g__InvoiceDate__c = System.Today(),c2g__InvoiceStatus__c = 'In Progress',
                                                                        c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 2',Credit_Manager__c = user1.Id,Program_Subscription__c= programSubscription.id);
            
            salesInvoiceList.add(salesInvoice);
            salesInvoiceList.add(salesInvoice2);
            insert salesInvoiceList;
            
           /* List<c2g__codaInvoiceLineItem__c> invoiceItemList = new  List<c2g__codaInvoiceLineItem__c>();
            c2g__codaInvoiceLineItem__c item = new c2g__codaInvoiceLineItem__c(
            CurrencyIsoCode = 'USD',
            c2g__DeriveLineNumber__c = true,
            c2g__LineDescription__c = 'Time Entry',
            c2g__Quantity__c = 1.0,
            c2g__TaxRate1__c = 0.0,
            c2g__TaxRate2__c = 0.0,
            c2g__TaxRate3__c = 0.0,
            c2g__TaxValue1__c = 0.0,
            c2g__TaxValue2__c = 0.0, 
            c2g__TaxValue3__c = 0.0,
            c2g__UnitOfWork__c = 1.0,
            c2g__UnitPrice__c = 180.0,
            c2g__UsePartPeriods__c = true,
            c2g__UseProductInformation__c = true,
            c2g__Invoice__c = salesInvoiceList[0].Id, 
            c2g__Product__c = product.Id
        );
            invoiceItemList.add(item);
            insert invoiceItemList;
            
            
            invoiceItemList[0].c2g__Quantity__c = 2.0;
            update invoiceItemList[0];*/
        }
    }
     
    @isTest static void test_RollupInvoiceAmtOnContract(){
        
      
       Test.startTest(); 
         //Bypass Dupeblocker
        Util.IsTest(true);
            
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
          List<c2g__codaInvoice__c> invoiceList = [select ContractABC__c, c2g__NetTotal__c, c2g__Transaction__r.Outstanding_Total_Minus_Taxes__c from c2g__codaInvoice__c ];
        
          set<Id> setOfContractId = new set<Id>();
          setOfContractId.add(invoiceList[0].ContractABC__c);
        
          InvoiceTriggerHelper.RollupInvoiceAmtOnContract(setOfContractId,true);
        test.stopTest();
    }
    
    //CR-20211112-15581 created testMethod
    @isTest static void test_getBillingContactsForSalesInvoice(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
            
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        // Query Account
        Account testAcc = [Select Id From Account Limit 1];
        Contract con = TestUtilities.createNewStandardContract(testAcc.Id, true);
        
        // get sales invoice
        List<c2g__codaInvoice__c> salesInvoiceList = [Select Id, Contract__c From c2g__codaInvoice__c Limit 1];
        salesInvoiceList[0].Contract__c = con.Id;
        update salesInvoiceList;
        
        // insert contact
        List<Contact> contact = new List<Contact>();
        contact.add(new Contact(LastName = 'TestContact3', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contact.add(new Contact(LastName = 'TestContact4', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        insert contact;
        
        // Create Invoice_Billing_Contact__c record
        List<Invoice_Billing_Contact__c> invoiceBillingContacts = new List<Invoice_Billing_Contact__c>();
        invoiceBillingContacts.add(new Invoice_Billing_Contact__c(Standard_Contract__c = salesInvoiceList[0].Contract__c, Contact__c = contact[0].Id, Enabled_for_this_Contract__c = true));
        
        insert invoiceBillingContacts;
        
        Test.startTest();
        
        // Call method
        List<InvoiceTriggerHelper.billingContactWrapper> wr = InvoiceTriggerHelper.getBillingContactsForSalesInvoice(salesInvoiceList[0].Id);
        System.assertEquals(2, wr.size());
        Test.stopTest();
        
    }
}