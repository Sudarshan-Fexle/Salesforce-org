/**
 *  Purpose         :   Test classs for the code coverage of SalesCreditNoteTriggerHelper class
 *
 *  Create By       :   Neha Sharma
 *
 *  Created Date    :   07/12/2021
 *
 *  Revision Logs   :   V_1.0 - Created - Neha Sharma - CR-20201113-14692 
 * 
 * Code Coverage    :	100%	
 *                 
**/
@isTest(seeAllData = false)
public class Test_SalesCreditNoteTriggerHelper 
{
    @testsetup static void testSetupData()
    { 
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        user1.phone = '3456787661';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
        System.runAs(user1) 
        {
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
            
            //List to hold Contract records to insert
            List<Contract> contracts = new List<Contract>();
            contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = testAcc.Id));
            contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15),ContractTerm = 30, AccountId = testAcc.Id));
            insert contracts;
            
            //List to hold Invoice Billing Schedule
            List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
            invoices.add(new Invoice_Billing_Schedule__c(Institution__c = testAcc.Id, Standard_Contract__c = contracts[0].Id));
            invoices.add(new Invoice_Billing_Schedule__c(Institution__c = testAcc.Id, Standard_Contract__c = contracts[1].Id));
            insert invoices;
            
			List<c2g__codaCreditNote__c> salesCredNotes = new List<c2g__codaCreditNote__c>();
            salesCredNotes.add(new c2g__codaCreditNote__c(c2g__Account__c = testAcc.Id, c2g__DueDate__c = System.today(), c2g__CreditNoteCurrency__c = testCurrency.Id,
                										  c2g__InvoiceDate__c = System.Today(),c2g__CreditNoteDate__c = System.Today(),c2g__CreditNoteStatus__c = 'In Progress', 
                                                    	  c2g__DerivePeriod__c = True, Program_Subscription__c = programSubscription.id, ffbext__Approved__c = false,
                                                          InvoiceBillingSchedule__c = invoices[0].Id));
            
        	//Util.BypassAllTriggers = false;
            insert salesCredNotes;
        }
        
    }
    
    @isTest static void test_populateContractOnSalesCreditNote()
    { 
        Util.BypassAllTriggers = false;
        List<Contract> contracts = [SELECT Id FROM Contract];
        System.assertEquals(2, contracts.size());
        
        List<Invoice_Billing_Schedule__c> invoices =  [SELECT Id FROM Invoice_Billing_Schedule__c];
        
        List<c2g__codaCreditNote__c> salesCredNotes = [SELECT Id, Contract__c FROM c2g__codaCreditNote__c];
        System.assertEquals(1, salesCredNotes.size());
        
        Test.startTest();
      
        salesCredNotes[0].InvoiceBillingSchedule__c = null;
        update salesCredNotes[0];
        
        List<c2g__codaCreditNote__c> listOfsalesCredNote = [SELECT Id,InvoiceBillingSchedule__c, Contract__c FROM c2g__codaCreditNote__c];
        System.assert(listOfsalesCredNote[0].Contract__c == null);

        listOfsalesCredNote[0].InvoiceBillingSchedule__c = invoices[1].Id;
        update listOfsalesCredNote[0];
        
        List<c2g__codaCreditNote__c> salesCredNotesAfterUpdate = [SELECT Id,InvoiceBillingSchedule__c, Contract__c FROM c2g__codaCreditNote__c];
        System.assert(salesCredNotesAfterUpdate[0].Contract__c != null);
        
        Test.stopTest();
    }
}