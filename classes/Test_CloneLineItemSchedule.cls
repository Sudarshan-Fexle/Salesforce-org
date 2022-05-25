/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_CloneLineItemSchedule {

    static testMethod void myUnitTest() {
    	// Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
        //fecth the existing record type from data base
        /*List<RecordType> listRecordType = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType
                                            where IsActive = true and SobjectType = 'Account' and DeveloperName ='US_Provider' limit 1];
        */
        //check for the list size
        /*if(listRecordType.size() > 0) {
            
            //create the account and contact sample data
            Account institution = new Account(Name = 'TestAccount', RecordTypeId = listRecordType[0].Id);
            insert institution;
            
            //insert the  Invoice Billing record
            Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
            insert invoiceBillingSchedule;
            
            //insert the program test data
            Program__c program = new Program__c(Name = 'TestProgram');
            insert program;
            
            //insert the Main contact record
            Contact mainContact = new Contact(LastName = 'TestLastName', AccountId = institution.Id, 
											Record_Type__c = listRecordType[0].Name, Email = 'Test'+Math.random()+'@eab.com', 
											Title = 'Test', Phone = '614-555-8855');
            insert mainContact;
            
            List<Contract__c> listContract = new List<Contract__c>();
            
            Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                                        Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                        Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                        Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id);
            insert contractABC;
            
            //Create LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
            Line_Item_Schedule__c lIS = new Line_Item_Schedule__c(Contract__c = contractABC.Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                                                                    Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                                    Amount__c = 20);
            insert lIS;
            
            //start test from here
            Test.startTest();
            
            //instantiate the controller class
            Clone_LineItemSchedule controller = new Clone_LineItemSchedule(new ApexPages.StandardController(lIS));
            
            //assert for the constructor properties
            Integer counter = [Select count() from Line_Item_Schedule__c where Contract__c =: contractABC.Id];
            System.assertEquals(1, counter);
            
            //insert the cone record
            controller.save();
            
            //assert for the constructor properties
            counter = [Select count() from Line_Item_Schedule__c where Contract__c =: contractABC.Id];
            System.assertEquals(2, counter);
            
            //Exception part coverage
            controller.save();
        }*/
    }
}