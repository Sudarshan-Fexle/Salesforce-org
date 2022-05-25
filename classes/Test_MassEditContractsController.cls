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
 //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2 - CR-20170403-10807
 //V_1.2 - Modified By Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
@isTest(seeAllData=false)
private class Test_MassEditContractsController {

    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers to easily create the test data 
        Util.byPassAllTriggers = true;
        
	 //Modified By Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
        //Fecth the existing record type from data base for Account
        /*List<RecordType> listRecordType = [SELECT Id FROM RecordType
                                            WHERE IsActive = true AND SobjectType = 'Account' AND DeveloperName ='US_Provider' LIMIT 1];
        */                                    
        //Fecthing record type for Contact
        List<RecordType> listContactRecordType = [SELECT Id FROM RecordType
                                                    WHERE IsActive = true AND sObjectType = 'Contact' AND DeveloperName = 'Employee' LIMIT 1];
                                                    
        //List to hold the record's type 
        List<RecordType> listOfSubscriptionRecordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
    								 	AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM LIMIT 1 ];                                            
                                                    
        
	 //Modified By Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
        //check for the list size
        if(/*listRecordType.size() > 0 &&*/ listContactRecordType.size() > 0) {
            
            //create the account and contact sample data
            Account institution = new Account(Name = 'TestAccount' /*, RecordTypeId = listRecordType[0].Id*/);
            insert institution;
            
            //insert the program test data
            Program__c program = new Program__c(Name = 'TestProgram');
            insert program;
            
            //List to hold the contact records
            List<Contact> contacts = new List<Contact>();
            
            //Contact records
            Contact contact_1 = new Contact(LastName = 'TestLastName1', AccountId = institution.Id, RecordTypeId = listContactRecordType[0].ID);
            Contact contact_2 = new Contact(LastName = 'TestLastName2', AccountId = institution.Id, RecordTypeId = listContactRecordType[0].ID);
            Contact contact_3 = new Contact(LastName = 'TestLastName3', AccountId = institution.Id, RecordTypeId = listContactRecordType[0].ID);
            Contact contact_4 = new Contact(LastName = 'TestLastName4', AccountId = institution.Id, RecordTypeId = listContactRecordType[0].ID);
            Contact contact_5 = new Contact(LastName = 'TestLastName5', AccountId = institution.Id, RecordTypeId = listContactRecordType[0].ID);
            
            //Populating list with records
            contacts.add(contact_1);
            contacts.add(contact_2);
            contacts.add(contact_3);
            contacts.add(contact_4);
            contacts.add(contact_5);
            insert contacts;
            
            //insert the  Invoice Billing record
            Invoice_Billing_Schedule__c invoiceBillingSchedule = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
            insert invoiceBillingSchedule;
            
            //List to hold the contract records
            List<Contract__c> listContract = new List<Contract__c>();
            
            //Contracts ABC records
            Contract__c contract_1 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test 1', Start__c = Date.today(), 
                                                            End__c = Date.today().addDays(1), 
                                                            Year__c = String.valueOf(System.today().year()), 
                                                            Program__c = program.Id, Join_Date__c = Date.today(),  
                                                            Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[1].Id,
                                                            Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id,
                                                            Invoice_Billing_Schedule__c = invoiceBillingSchedule.ID);
                                                            
            Contract__c contract_2 = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test 2', Start__c = Date.today(), End__c = Date.today().addDays(1), 
                                                            Year__c = String.valueOf(System.today().year()), Program__c = program.Id, Join_Date__c = Date.today(),  
                                                            Main_Contact__c = contacts[2].Id, Invoice_Contact__c = contacts[3].Id,
                                                            Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id,
                                                            Invoice_Billing_Schedule__c = invoiceBillingSchedule.ID);
            
            //Populating list with records
            listContract.add(contract_1);
            listContract.add(contract_2);
            insert listContract;
            
            //List to hold subscription  
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2 - CR-20170403-10807 - Start here
	        List<SBQQ__Subscription__c> listSubscription = new List<SBQQ__Subscription__c>();  
	
	        //Add new subscription record in list
	        listSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, RecordTypeId = listOfSubscriptionRecordTypes[0].Id,
	                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 5,
	                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
	                                                    Status__c = 'Committed', Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id,
	                                                    Invoice_Contact__c = contacts[0].Id));
	                                                    
	        listSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 10, RecordTypeId = listOfSubscriptionRecordTypes[0].Id,
	                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 6,
	                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
	                                                    Status__c = 'Pending', Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id,
	                                                    Invoice_Contact__c = contacts[1].Id)); 
            
	        
            //Bypass All trigger
            Util.ByPassAllTriggers = true;
            
            //Insert the subscription record list 
	        insert listSubscription;
            
             //Bypass All trigger
            Util.ByPassAllTriggers = false;
            
	        //Stop here
            //Start Test from here
            Test.startTest();
            
            //Loading the VF page
            Apexpages.currentPage().getParameters().put('id', String.valueOf(invoiceBillingSchedule.ID));
            Apexpages.currentPage().getParameters().put('conid', String.valueOf(listContract[0].Id));
            
            //For the subscription record's id 
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2-  CR-20170403-10807
            Apexpages.currentPage().getParameters().put('subsid', String.valueOf(listSubscription[0].Id));
            
            MassEditContractsController controller = new MassEditContractsController();
            
            //Assert for the results
            System.assertEquals(1, controller.contracts.size());
            //System.assertEquals(2, controller.allRecordsSize);
            
            //Assert for the subscription
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2-  CR-20170403-10807
            System.assertEquals(1, controller.listOfSubscription.size());
            System.assertEquals(2, controller.proSubscriptionRecordsSize);
            
            //Setting update scope on the page
            controller.updateScope = 'selected';
            
            //Populating main contact on the page
            controller.contract.Main_Contact__c = contacts[2].Id;
            
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2-  CR-20170403-10807
            controller.subscription.Invoice_Contact__c = contacts[2].Id;
            
            //Click on the save button
            controller.saveContracts();
            
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2-  CR-20170403-10807
            //Call the controller' saveSubscriptions method 
            controller.saveSubscriptions();
            
            //List to hold the contrat records
            List<contract__c> updatedContracts = new List<Contract__c>();
            
            //Quering for the contract records details
            updatedContracts = [SELECT ID, Main_Contact__c, Invoice_Contact__c FROM Contract__c ORDER BY Type__c ASC];
            
            //Query through the updated Subscription records details
            //V_1.1 - Modified - Deepak Kumar -Q2C Phase 2-  CR-20170403-10807 - Start here 
            listSubscription = [Select Id, Invoice_Contact__c From SBQQ__Subscription__c Order By Name];
            
            //Asserting for the results
            System.assertEquals(contacts[2].Id, listSubscription[0].Invoice_Contact__c);
            //Stop here
            
            //Asserting for the results
            System.assertEquals(contacts[2].Id, updatedContracts[0].Main_Contact__c);
            //System.assertEquals(contacts[2].Id, updatedContracts[1].Main_Contact__c);
            //System.assertEquals(contacts[1].Id, updatedContracts[0].Invoice_Contact__c);
            //System.assertEquals(contacts[3].Id, updatedContracts[1].Invoice_Contact__c);
            
            //Setting update scope on the page
            controller.updateScope = 'all';
            
            //Populating main contact on the page
            controller.contract.Main_Contact__c = contacts[4].Id;
            controller.contract.Invoice_Contact__c = contacts[0].Id;
            
            controller.subscription.Invoice_Contact__c = contacts[3].Id;
            
            //Click on the save button
            controller.saveContracts();
            controller.saveSubscriptions();
            
            //Quering for the contract records details
            updatedContracts = [SELECT ID, Main_Contact__c, Invoice_Contact__c FROM Contract__c ORDER BY Type__c ASC];
            
            //Query through the updated Subscription records details
            listSubscription = [Select Id, Invoice_Contact__c From SBQQ__Subscription__c Order By Name];
            
            //Asserting for the results
            System.assertEquals(contacts[3].Id, listSubscription[0].Invoice_Contact__c);
            System.assertEquals(contacts[3].Id, listSubscription[1].Invoice_Contact__c);
            
            //Asserting for the results
            //System.assertEquals(contacts[4].Id, updatedContracts[0].Main_Contact__c);
            //System.assertEquals(contacts[4].Id, updatedContracts[1].Main_Contact__c);
            //System.assertEquals(contacts[0].Id, updatedContracts[0].Invoice_Contact__c);
            //System.assertEquals(contacts[0].Id, updatedContracts[1].Invoice_Contact__c);
            
            //Click on Cancel button
            controller.doCancel();
            
            //Stop Test here
            Test.stopTest();
        }
    }
}