// Modified By - Colin McGloin - CR-20200715-14316
// Modfied By - Mahendra Swarnkar - CR-20211112-15581 -11/29/2021 - Added test method for updateInvoiceBillingContact
@isTest
public class Test_InvoiceBillingContactTriggerHelper {

    static testmethod void importInvoiceBillingContacts(){

        Account account = TestUtilities.CreateNewAccount(true);
        Contract con = TestUtilities.createNewStandardContract(account.Id, true);

        //Create Contacts
        Contact con1 = TestUtilities.CreateNewContact(account, true);
        Contact con2 = TestUtilities.CreateNewContact(account, true);
        Contact con3 = TestUtilities.CreateNewContact(account, true);

        //Set the Enabled for Invoice field for 2 of them
        con1.Enabled_for_Invoice__c = true;
        con2.Enabled_for_Invoice__c = true;
        List<Contact> cons = new List<Contact>();
        cons.add(con1);
        cons.add(con2);
        update cons;
        
        Test.startTest();
        
        //Run our Import Method
        InvoiceBillingContactTriggerHelper.importInvoiceBillingContacts(con.Id);

        //Query to run our Assertions
        List <Invoice_Billing_Contact__c> relatedIBC = [SELECT Id, Name, Contact__c, Contact_Name__c, Standard_Contract__c, Contract_Name__c, Invoice_Email__c, Enabled_for_this_Contract__c
                                                        FROM Invoice_Billing_Contact__c
                                                        WHERE Standard_Contract__c = :con.Id];

        //Check the Assertions
        system.assertEquals(2, relatedIBC.size());
	
	Test.stopTest();
        
        Object objToserialize = (Object)JSON.serialize(relatedIBC);
        String resultMessage = InvoiceBillingContactTriggerHelper.updateInvoiceBillingContact(objToserialize);
        
    }
}