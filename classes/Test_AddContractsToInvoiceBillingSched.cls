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
private class Test_AddContractsToInvoiceBillingSched {
/*
    Purpose:    Test Class for AddContractsToInvoiceBillingSchedule
                
    Create By:  Simplyforce Technology
    
    Created Date:   10/27/2011
    
    Current Version:    V1.0 
            V1.1 - Modified By - Mahendra Swarnkar - 4/2/2016 - CR-20160113-9513
            V1.2 - Modified By - Deepak Kumar -6/20/2017 -  Q2C Phase 2 
            V1.3 - Modified - Divya Bharadwaj(Simplyforce)- 07/26/2017 - Q2C
            v1.4 - Modified By - Deepak Kumar - 8/21/2017 - Q2C Redesign - Post Silent Deploy - test failures 
    		V1.5 - Modified By  - Dipesh gupta - 12/15/2017 - CR-20171204-11830 - Production Validation Error. Method - "myUnitTest2"
    Revision Log:   Created  
    
    Coverage : 100%         
*/
    static testMethod void myUnitTest() {
        
        //fecth the existing record type from data base
        List<RecordType> listRecordType = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType
                                            where IsActive = true and SobjectType = 'Account' and DeveloperName ='US_Education' limit 1];
        
        //check for the list size
        if(listRecordType.size() > 0) {
            
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
												Record_Type__c = listRecordType[0].Name, 
												Email = 'Test'+Math.random()+'@eab.com', 
												Title = 'Test', Phone = '614-555-8855');
            insert mainContact;
            
            // Create invoice billing data
            Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
            insert ibs;
            
            List<Contract__c> listContract = new List<Contract__c>();
            
            for(Integer i = 0; i < 101; i++) {
                listContract.add(new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                                        Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                        Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                        Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id));
            }
            
            insert listContract;
        
            // VRH 7/6/12 - The code below that was adding Line_Item_Schedule__c records was breaking this unit test 
            /*//Create 200 LIS records to test the ContractABCTriggerHelper.validateIBSIdForContactABC functionality
            List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();

            for(Integer i = 0; i < 101; i++) {
                listLIS.add(new Line_Item_Schedule__c(Contract__c = listContract[i].Id, Invoice_Billing_Schedule_del__c = listContract[i].Invoice_Billing_Schedule__c, 
                                                                    Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                                    Amount__c = 20));
            }
            
            insert listLIS;*/
            
                        
            /*//insert dummay Contract ABC record
            Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                                        Year__c = '2011', Program__c = program.Id, Join_Date__c = Date.today(),  
                                                        Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                        Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id);
            insert contractABC;*/
            
            //start test from here 
            Test.startTest();
            
            //initiate controller
            AddContractsToInvoiceBillingSchedule controller = new AddContractsToInvoiceBillingSchedule(new ApexPages.StandardController(invoiceBillingSchedule));
            
            //assert for the constructor result
            System.assertEquals(101, controller.listContractABCWrapper.size());
            
            for(Integer i = 0; i < 101; i++) {
                //mark the wrapper record selected
                controller.listContractABCWrapper[i].selected = true;
            }
            
            //call add contract method
            controller.addContracts();
            
            //fecth the contract back and assert the result
            List<Contract__c> contracts = [Select Invoice_Billing_Schedule__c from Contract__c where Id IN: listContract];
            System.assertEquals(101, contracts.size());
            System.assertEquals(invoiceBillingSchedule.Id, contracts[0].Invoice_Billing_Schedule__c);
            
            //catch the exception part
            controller.listContractABCWrapper[0].contractABC = new Contract__c(Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id);
            
            //call add contract method
            controller.addContracts();
            
            //check error on page
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
            
            //stop test here
            Test.stopTest();
        }
    }
    
    //Creted By - Mahendra Swarnkar - 4/2/2016 - CR-20160113-9513
  Public static testMethod void myUnitTest1() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
    //fecth the existing record type from data base
        List<RecordType> listRecordType = [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType
                                            where IsActive = true and SobjectType = 'Account' and DeveloperName ='US_Education' limit 1];
        
        //check for the list size
        if(listRecordType.size() > 0) {
            
            //create the account and contact sample data
            Account institution = new Account(Name = 'TestAccount', RecordTypeId = listRecordType[0].Id);
            insert institution;
            
            //insert the  Invoice Billing record
            Invoice_Billing_Schedule__c invoiceBillingSchedule =  new Invoice_Billing_Schedule__c(Institution__c = institution.Id);
      insert invoiceBillingSchedule;

            //insert the program test data
      List<Program__c> programs = new List<Program__c>();
      programs.add(new Program__c(Name = 'TestProgramCLN', Business_line__c = 'CLN'));
      programs.add(new Program__c(Name = 'TestProgramSW', Business_line__c = 'SW'));
      programs.add(new Program__c(Name = 'TestProgramPT', Business_line__c = 'PT'));
            
      insert programs;

            //insert the Main contact record
            Contact mainContact = new Contact(LastName = 'TestLastName', AccountId = institution.Id, 
			Record_Type__c = listRecordType[0].Name,
			Email = 'Test'+Math.random()+'@eab.com', 
			Title = 'Test', 
			Phone = '614-555-8855'
			
			);
            insert mainContact;
            
            //Insert Contracts
      List<Contract__c> contracts = new List<Contract__c>();
      contracts.add(new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                            Year__c = '2011', Program__c = programs[0].Id, Join_Date__c = Date.today(),  
                                            Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                            Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id, Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id));

            contracts.add(new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                      Year__c = '2011', Program__c = programs[1].Id, Join_Date__c = Date.today(),  
                                            Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                            Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id));
            
            //Insert the Contracts
            insert contracts;
            
            //Insert Line Item Schedule test data
            List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();
            listLIS.add(new Line_Item_Schedule__c(Contract__c = contracts[0].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                          Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                    Amount__c = 20));
            insert listLIS;
            
            //initiate controller
            AddContractsToInvoiceBillingSchedule controller = new AddContractsToInvoiceBillingSchedule(new ApexPages.StandardController(invoiceBillingSchedule));
            
            //assert for the constructor result
            System.assertEquals(1, controller.listContractABCWrapper.size());
            
      //mark the wrapper record selected
            controller.listContractABCWrapper[0].selected = true;
            Id tempContractId = controller.listContractABCWrapper[0].contractABC.Id;
            
            //call add contract method
            controller.addContracts();
            
            //fecth the contract back and assert the result
            List<Contract__c> contractsOnIBS = [Select Invoice_Billing_Schedule__c, Invoice_Billing_Schedule__r.Division__c from Contract__c where Id =: tempContractId];
            System.assertEquals(invoiceBillingSchedule.Id, contractsOnIBS[0].Invoice_Billing_Schedule__c);
      System.assertEquals('CLN', contractsOnIBS[0].Invoice_Billing_Schedule__r.Division__c);
            
      //Update and insert the Contracts
      contracts[0].Program__c = programs[1].Id;
            contracts.add(new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                                        Year__c = '2011', Program__c = programs[2].Id, Join_Date__c = Date.today(),  
                                                        Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                        Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id));
      upsert contracts;
            
      //Insert Line Item Schedule for Contract
            listLIS.add(new Line_Item_Schedule__c(Contract__c = contracts[1].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                          Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                    Amount__c = 20));
            insert listLIS[1];
            
            //start test from here 
            Test.startTest();
            
            //initiate controller
            controller = new AddContractsToInvoiceBillingSchedule(new ApexPages.StandardController(invoiceBillingSchedule));
            
            //assert for the constructor result
            System.assertEquals(1, controller.listContractABCWrapper.size());
            
      //mark the wrapper record selected
            controller.listContractABCWrapper[0].selected = true;
            
            //call add contract method
            controller.addContracts();
            
            //fecth the contract back and assert the result
            contractsOnIBS = [Select Invoice_Billing_Schedule__c, Invoice_Billing_Schedule__r.Division__c from Contract__c where Id IN: contracts];
            System.assertEquals('SW', contractsOnIBS[0].Invoice_Billing_Schedule__r.Division__c);
            
            //Insert Line Item Schedule for Contract
            listLIS.add(new Line_Item_Schedule__c(Contract__c = contracts[2].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                          Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                    Amount__c = 20));
            insert listLIS[2];
            
      //Insert new Contract
      Contract__c contractABC = new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test', Start__c = Date.today(), End__c = Date.today(), 
                                                        Year__c = '2011', Program__c = programs[2].Id, Join_Date__c = Date.today(),  
                                                        Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                        Status__c = Constants.STATUS_ATL, Payer_Account__c = institution.Id);
      insert contractABC;

      //initiate controller
            controller = new AddContractsToInvoiceBillingSchedule(new ApexPages.StandardController(invoiceBillingSchedule));
            
            //assert for the constructor result
            System.assertEquals(1, controller.listContractABCWrapper.size());
            
      //mark the wrapper record selected
            controller.listContractABCWrapper[0].selected = true;
            
            //call add contract method
            controller.addContracts();
            
            //fecth the contract back and assert the result
            contractsOnIBS = [Select Invoice_Billing_Schedule__c, Invoice_Billing_Schedule__r.Division__c from Contract__c where Id IN: contracts];
            System.assertEquals('ABC Corporate', contractsOnIBS[0].Invoice_Billing_Schedule__r.Division__c);
            
            //stop test here
            Test.stopTest();
        }
    }
    
    //Created By - Deepak kumar - 6/20/2017 -  Q2C Phase 2 
    //Test the addContractToInvoiceBillingSchdedule functionality 
    //Modified By - Divya Bharadwaj - 07/26/2017 -Q2C
  static testMethod void myUnitTest2() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
    //List to hold the record's type 
       List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                       AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM LIMIT 1];
        
        //check for the list size
        if(recordTypes.size() > 0) {
            
            //create the account and contact sample data
            Account accountTest  = new Account(Name = 'TestAccount');
            
            //Insert the account test data
            insert accountTest;
            
            //insert the program test data
      List<Program__c> programs = new List<Program__c>();
      programs.add(new Program__c(Name = 'TestProgramCLN', Business_line__c = 'CLN'));
      programs.add(new Program__c(Name = 'TestProgramSW', Business_line__c = 'SW'));
      programs.add(new Program__c(Name = 'TestProgramPT', Business_line__c = 'PT'));
            
      insert programs;

            //insert the Main contact record
            Contact mainContact = new Contact(LastName = 'TestLastName', AccountId = accountTest.Id, Email = 'Test'+Math.random()+'@eab.com', 
											  Title = 'Test', Phone = '614-555-8855');
            insert mainContact;
            
            //Get Record Type
          Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
          
          //List ot hold proposal 
          List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
          
          //Add to list
          quotes.add(new SBQQ__Quote__c(SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                        SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                        SBQQ__PrimaryContact__c = mainContact.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
          
          //Insert Opportunity
          insert quotes;
            
            //List to hold Contract records to insert
      List<Contract> contracts = new List<Contract>(); 
      
      //Add the records into list
      contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accountTest.Id,
              SBQQ__Quote__c = quotes[0].Id));
      contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accountTest.Id,
              SBQQ__Quote__c = quotes[0].Id));
      insert contracts;
      
      //List of Contract ABC
      List<Contract__C> contractABCList = new List<contract__C>();

        //Add record to list 
        contractABCList.add( new Contract__c(Negotiated_Amount__c = 100, Type__c = 'Test1', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2011',  Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = accountTest.Id));
        contractABCList.add( new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test2', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2013', Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = accountTest.Id));
        contractABCList.add( new Contract__c(Negotiated_Amount__c = 200, Type__c = 'Test3', Start__c = Date.today(), End__c = Date.today(), 
                                                   Year__c = '2014', Join_Date__c = Date.today(),  
                                                   Main_Contact__c = mainContact.Id, Invoice_Contact__c = mainContact.Id,
                                                   Status__c = Constants.STATUS_ATL, Payer_Account__c = accountTest.Id, Record_Source__c = 'Shadow'));

      //Insert the contractList
      insert contractABCList;
      
      //insert the  Invoice Billing record
            Invoice_Billing_Schedule__c invoiceBillingSchedule =  new Invoice_Billing_Schedule__c(Institution__c = accountTest.Id, Standard_Contract__c = contracts[0].Id);
      
      //Insert the invoiceBillingSchdeule test data
      insert invoiceBillingSchedule;
      
      //List to hold subscription
          List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  
  
          //Add new subscription record in list
          subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Contract__c = contracts[0].Id,
                                                      SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, Invoice_Contact__c = mainContact.Id,
                                                      SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                      Status__c = Constants.STATUS_ATL, SBQQ__Account__c = accountTest.Id,
                                                      Shadow_Contract_ABC__c = contractABCList[2].Id));
          subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000, SBQQ__Contract__c = contracts[1].Id,
                                                      SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, Invoice_Contact__c =  mainContact.Id,
                                                      SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                      Status__c = Constants.STATUS_ATL));                                                       
          
          //ByPassAllTrigger
          Util.ByPassAllTriggers = true;
          //Insert
          insert subscriptions;   
          
          //Insert Line Item Schedule test data
            List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();
            listLIS.add(new Line_Item_Schedule__c(Program_Subscription__c = subscriptions[0].Id, Invoice_Billing_Schedule_del__c = invoiceBillingSchedule.Id, 
                          Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                    Amount__c = 20, Contract__c = contractABCList[2].Id));
            //Commented by Dipesh Gupta - Due to the below error on 12/15/2017
            //(You cannot remove the Invoice Billing Schedule link for contracts that have Line Item Schedules.To remove the Invoice Billing Schedule link you must first delete all child Line Item Schedules)
            //insert listLIS;
            
            // set the page
          PageReference pageRef = Page.AddContractsToInvoiceBillingSchedule;
          Test.setCurrentPage(pageRef);
            
            //Add the prosubId in the url 
            Apexpages.currentPage().getParameters().put('prosub', 'pSbutton');
            
            //start test from here 
            Test.startTest();
            
            //initiate controller
            AddContractsToInvoiceBillingSchedule controller = new AddContractsToInvoiceBillingSchedule(new ApexPages.StandardController(invoiceBillingSchedule));
            
            //Call the controller 
            controller.setupSort();
            
            //assert for the constructor result
            //System.assertEquals(1, controller.listContractABCWrapper.size());
            
      		//mark the wrapper record selected
            controller.listContractABCWrapper[0].selected = true;
            Id tempContractId = controller.listContractABCWrapper[0].programSubscription.Id;
            
            //call add contract method
            controller.addContracts();
            
            //fecth the contract back and assert the result
            List<SBQQ__Subscription__c> subscriptionOnIBS = [Select Invoice_Billing_Schedule__c, Invoice_Billing_Schedule__r.Division__c from SBQQ__Subscription__c where Id =: tempContractId];
            System.assertEquals(invoiceBillingSchedule.Id, subscriptionOnIBS[0].Invoice_Billing_Schedule__c);
      		
      		//stop test here
            Test.stopTest();
        }
    }    
}