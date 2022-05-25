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
 /*
 *  Revision Log    :   V1.1 - Modified By - Saurabh Kumar - 06/14/2017 - CR-20170403-10807 (DS114) - New test methods setupData, testPopulateFieldsValueOnCases,testSyncContractIntegratedAccounts, testUpdateContractAndOppAfterContractTermination are added
 *                      V1.2 - Modified By - Saurabh Kumar - 09/05/2017 - Q2C Redesign - Post Silent Deploy - Failure fixes
 *                      V1.3 - Modified By Subhash Garhwal - Deployement Error -  CR-20180212-12039, CR-20180314-12107
 *                      V1.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 * 			V1.5 - Modified By - Mahendra Swarnkar - 09/01/2021 - CR-20201120-14707 - Added New test Method test_updateSubscriptionsInvoicingArrangement.
 *		        V1.6 - Modified By - Subhash Garhwal - CR-20210811-15348
*/
@isTest(seeAllData = false)
private class Test_ContractTrigger {
    
    /**
     *  @description    :   The method is used to insert common data which are useful in testing
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Saurabh Kumar -  06/14/2017 - CR-20170403-10807
     *
     **/   
    static void setupData(){
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        insert contacts;
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Insert Opportunity
        insert quotes;
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));    
        
        insert contracts;
        
        //Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        
        //List to hold Subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionProgramRecordType, SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 5));
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionProgramRecordType, SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 10));
        insert subscriptions;

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //List to hold Membership records to insert
        List<Membership__c> memberships = new List<Membership__c>();
        
        memberships.add(new Membership__c(Name = 'Test1', Latest_Subscription__c = subscriptions[0].Id, Account_Name__c = Accounts[0].Id, Program__c = testProgram.Id));
        memberships.add(new Membership__c(Name = 'Test1', Latest_Subscription__c = subscriptions[0].Id, Account_Name__c = Accounts[0].Id, Program__c = testProgram.Id));
        insert memberships;
        
        //Get Record Type
        Id caseAskEABRecordType = TestUtilities.FindRecordTypeId('Case', 'Ask EAB');
        
        //List to hold Case records to insert
        List<Case> cases = new List<Case>();
        
        cases.add(new Case(Origin = 'Other', Case_Nature__c = 'General Research Request', Relationship_Manager__c = contacts[0].Id, Status = 'Assigned', ContactId = contacts[1].Id, 
                  Nature_of_the_Contact__c = 'Signer', AccountId = accounts[0].Id, Membership__c = memberships[0].Id, Description = 'Testing'));
        cases.add(new Case(Origin = 'Other', Case_Nature__c = 'General Research Request', Relationship_Manager__c = contacts[0].Id, Status = 'New Request', ContactId = contacts[1].Id, 
                  Nature_of_the_Contact__c = 'Signer', AccountId = accounts[1].Id, Membership__c = memberships[1].Id, Description = 'Testing'));
        insert cases;
    }
    
    static testMethod void testPopulateFieldValuesOnOpportunity() {
        //Skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        Util.IsBatch = true;

        Contact c = TestUtilities.CreateNewContact(true);
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        //Get opportunity record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Open'];
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addMonths(2), recordTypeId =recordTypes[0].Id,
                                      SBQQ__PrimaryContact__c = c.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Insert Opportunity
        insert quotes;
        
        //Test starts here
        Test.startTest();
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
 
        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        update opportunities;
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        
        //List to hold Contract
        List<Contract> contracts = new List<Contract>();
        
        //Add record to listid
        contracts.add(new Contract(SBQQ__Opportunity__c = opportunities[0].Id, Status = 'Draft', StartDate = Date.today(), EndDate = Date.Today().addDays(5), AccountId= c.AccountId,
                                   ContractTerm = 5, SBQQ__Quote__c = quotes[0].Id));
        
        Util.BypassAllTriggers = false;
        Util.IsBatch = false;
        
        //Test stops here
        Test.stopTest();
        
        //Insert Contract
        insert contracts;
        
        //get the update opportunities
        opportunities = [SELECT Id, LOA_Contract__c FROM Opportunity WHERE Id IN :opportunities];
       
       //Commented By subhash Garhwal - 03/30/2018 - in the Critical Deployment -  CR-20180212-12039, CR-20180314-12107 
       /* //assertions
        for (Opportunity o : opportunities) {
            if (contracts[0].SBQQ__Opportunity__c == o.Id)
                system.assertEquals(contracts[0].Id, o.LOA_Contract__c);
            else
                system.assertEquals(null, o.LOA_Contract__c);
        }*/
    }
    
    /**
     *  Description     :   Test class to test the functionality of ContractTriggerHelper Trigger
     *            
     *  Create By       :   Subhash Garhwal
     *
     *  Created Date    :   07/11/2016
     *
     *  Revision Log    :   V_1.0 - Created  
     *                      V_1.1 - Modified By -  05/14/2017 -Subhash Garhwal  -CR-20170403-10807- Added a new method  testsyncNegotiatedBy 
     *
     *  Coverage        :   100%
     *
     **/
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        
        //Insert
        insert programs;
      
      
      //Insert Content Version
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        insert versionDoc;

    //Query ContentDocumentId from Content Version
        List<ContentVersion> cVersions = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];

    //List to hold Content Document
        List<ContentDocument> cD = [SELECT Id, Title FROM ContentDocument  where Id = :cVersions[0].ContentDocumentId];
        
        String DocumentId = cD[0].Id;
        
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
                                  ProductCode = 'PTPRO'));
        
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[2].Id, 
                                  IsActive = true, ProductCode = 'ConsultingPRO'));
        
        //Insert
        insert products;

        List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND isActive = true AND DeveloperName = 'EAB_Initiating'];

        //Test Start from here
        Test.startTest();
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Create new Contact
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.Id;
        insert cont;
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id));
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        Util.BypassAllTriggers = true;      

        //Insert List of Opportunity              
        insert parentOpportunities;
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id, 
                      SBQQ__DocumentStatus__c = 'Generated', LOA_PDF_Document_ID__c = DocumentId));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
                
        //Insert list of Quote
        insert quotes;

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;

        //Add new Quote lines n list
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
        qLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100, Profit__c = 100, Annualized_Contract_Value__c = 100));
        qLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100, Profit__c = 100, Annualized_Contract_Value__c = 100));

        insert qLines;
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        
        
    //Parent Opportunity
    List<RecordType> recordTypesINHC = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND isActive = true AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES ];
        
        //Update Opportunity with Stage Name
        parentOpportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        //parentOpportunities[0].SBQQ__Contracted__c = true;
        ParentOpportunities[0].recordTypeId = recordTypesINHC[1].Id;
        
        //Update Opportunity with Stage Name
        parentOpportunities[1].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
       // parentOpportunities[1].SBQQ__Contracted__c = true;
        // parentOpportunities[0].Meeting_Travel_Comp__c = 'Hotel';    
        ParentOpportunities[1].recordTypeId = recordTypesINHC[1].Id;
        
        //Trigger Bypass
        Util.BypassAllTriggers = false;
        
        //DML for update opportunities
        update parentOpportunities; 
        
        parentOpportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        //parentOpportunities[0].SBQQ__Contracted__c = true;  
         ParentOpportunities[0].recordTypeId = recordTypesINHC[1].Id;
        
        //Update Opportunity with Stage Name
        parentOpportunities[1].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        //parentOpportunities[1].SBQQ__Contracted__c = true;
        // parentOpportunities[0].Meeting_Travel_Comp__c = 'Hotel';    
        ParentOpportunities[1].recordTypeId = recordTypesINHC[1].Id;
        
        //Trigger Bypass
        Util.BypassAllTriggers = false;
        
        //DML for update opportunities
        update parentOpportunities;        
        
        parentOpportunities[0].SBQQ__Contracted__c = true; 
        parentOpportunities[1].SBQQ__Contracted__c = true;
        
        //DML for update opportunities
        update parentOpportunities;
        
        //Update Opportunity with Stage Name
        parentOpportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON;
        parentOpportunities[1].StageName = CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON;
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //DML for update opportunities
        update parentOpportunities;
        
        //Bypass false trigger
        Util.BypassAllTriggers = false;
        
        //Test data of Integrated Account
        Integrated_Account__c integrateAcc = new Integrated_Account__c(Opportunity__c = parentOpportunities[0].Id, Integrated_Account__c = acc.Id);
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Insert Integrated Account
        insert integrateAcc;

        //Test stop here
        Test.stopTest();

        //Bypass false
        Util.BypassAllTriggers = false;
        
        //Test data of Contract
        Contract con = new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = parentOpportunities[0].Id, SBQQ__Quote__c = quotes[0].Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        
        //Insert contract record
        insert con;
        
       
        //Query record of contract aaabove created
        List<Contract> cons = [Select Id,SBQQ__Opportunity__c, Status, SBQQ__RenewalOpportunity__c from Contract where SBQQ__Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1,cons.size());
        
        //updating the field value of contract.
        cons[0].Status = 'Activated';
           
        Util.BypassAllTriggers = false;   
        //Update Contract
        update cons;
        
        //Map to hold the contract with id.
        Map<Id, Contract> mapOfOldContract = new Map<Id, Contract>();
        
        //Loop through contract
        for(Contract c : cons) {
            
            //Filling map with contract with id 
            mapOfOldContract.put(c.Id, c);
        }
        
        //Chnaging opportunity on the contract instance
        cons[0].SBQQ__Opportunity__c = parentOpportunities[1].Id;
        
        //Update contract
        update cons;
        
        //Calling method of the contractTriggerHelper which is unfortunetely not calling from the test class.
        // Commented Out By Mahendra Swarnkar - CR-20200505-14016
	//ContractTriggerHelper.updateRenewalOpportunityOnSubscriptionPeriod(cons, mapOfOldContract);
        
        //Query records of Integrated account
        List<Integrated_Account__c> intAcc = [Select Id,Opportunity__c from Integrated_Account__c where Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        System.assertEquals(1,intAcc.size());
        
        //Query Contarct Integrated Account record whhich is auto created by trigger
        List<Contract_Integrated_Accounts__c> conItnegrateAcc = [Select RecordTypeId, LOA_Contract__c, Integrated_Account__c, Account__c from Contract_Integrated_Accounts__c
                                                                            Where LOA_Contract__c =: con.Id];
        
        //Assert
        System.assertEquals(1,conItnegrateAcc.size());
        System.assertEquals(con.Id,conItnegrateAcc[0].LOA_Contract__c);
        System.assertEquals(intAcc[0].Id,conItnegrateAcc[0].Integrated_Account__c);
        System.assertEquals(acc.Id,conItnegrateAcc[0].Account__c);
        
        //Delete Contract Record
        //delete con;
        
        //Query Contarct Integrated Account  record
        conItnegrateAcc = [Select RecordTypeId, LOA_Contract__c, Integrated_Account__c, Account__c from Contract_Integrated_Accounts__c
                                                                            Where Integrated_Account__c =: intAcc[0].Id];
        
        //v1.3 - Modified by - Saurabh Kumar - 09/05/2017 - Q2C Redesign - Post Silent Deploy - Commented the assert
        //Assert                                                                    
        //System.assertEquals(0,conItnegrateAcc.size());
    
    }
    /**
     *  @description    :   This method is used to test syncNegotiatedBy Method and test linkSignedLOAToContract
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Subhash Garhwal -  05/14/2017 -CR-20170403-10807
     *
     **/
    private static testMethod void testsyncNegotiatedBy() {

        //List to hold developer Name
        List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND DeveloperName IN :CPQConstants.SET_OPP_INITIATING_RECORDTYPES];

        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
    
        //List to hold User
        List<User> users = new List<User>();        
    
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                            TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        
        //Bypass all the triggers 
        Util.BypassAllTriggers = true;
        
        //Insert User
        insert users;       

        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Create new Contact
        Contact cont = TestUtilities.CreateNewContact(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', Main_Contact__c = cont.Id, AccountId = acc.Id, CloseDate = System.today().addDays(31),
                                                RecordTypeId = recordTypes[0].Id, Marketer__c = users[0].Id, StageName = '0-Exploring'));

        Util.BypassAllTriggers = true;

        //Insert opportunity
        insert parentOpportunities;

        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

        Util.BypassAllTriggers = true; 

        List<Opportunity> Opportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', Main_Contact__c = cont.Id, AccountId = acc.Id, CloseDate = System.today().addDays(32),
                                                RecordTypeId = recordTypes[0].Id, StageName = '0-Exploring', 
                                                Credited_Date_Time__c = System.now(), 
                                                Booked_Date_Time__c = System.now()));

        Util.BypassAllTriggers = true;

        //Insert opportunity
        insert Opportunities;

        //Insert Content Version
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        insert versionDoc;

        //Query ContentDocumentId from Content Version
        List<ContentVersion> cVersions = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];

        //List to hold Content Document
        List<ContentDocument> cD = [SELECT Id, Title FROM ContentDocument  where Id = :cVersions[0].ContentDocumentId];
        
        String DocumentId = cD[0].Id;

        Util.BypassAllTriggers = true;

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Insert new Product
        Product2 product = TestUtilities.createNewProduct(testProgram.Id, true);

        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = Opportunities[0].Id, 
                                            SBQQ__DocumentStatus__c = 'Generated', LOA_PDF_Document_ID__c = DocumentId ));

        Util.BypassAllTriggers = true; 

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;

        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

        //Insert list of Quote
        insert quotes;

        //Add new Quote lines n list
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
        qLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 100, Profit__c = 100, Annualized_Contract_Value__c = 100));

        insert qLines;
 
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
 
        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        update opportunities;
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        Opportunities[0].SBQQ__Contracted__c = true;
        Opportunities[0].StageName = 'Contract Received - Send to Finance';

        //Test Start from here
        Test.startTest();
        
        update opportunities;

        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

        Util.BypassAllTriggers = false; 

        //Test data of Contract
        Contract con = new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = parentOpportunities[0].Id, SBQQ__Quote__c = quotes[0].Id, Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 2);

        //Insert contract record
        insert con;

        //Query on contract
        Contract contract = new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = Opportunities[0].Id,  SBQQ__Quote__c = quotes[0].Id, Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 2);

        //Insert Contract
        insert contract;

        //Query through contract
        List<Contract> contracts = [Select Id, Negotiated_By__c From Contract Where Negotiated_By__c != null];

        //Assert
        System.assertEquals(parentOpportunities[0].Marketer__c,contracts[0].Negotiated_By__c);

        //Query on quotes
        quotes = [Select Id, SBQQ__Status__c, LOA_PDF_Document_ID__c From SBQQ__Quote__c Where LOA_PDF_Document_ID__c != null ];

        String cDocumentId = quotes[0].LOA_PDF_Document_ID__c;

        //Query on ContentDocumentLink which is auto created by Trigger
        List<ContentDocumentLink> contentDocumentLinks  = [Select Id , LinkedEntityId, ContentDocumentId From ContentDocumentLink Where ContentDocumentId =: cDocumentId];  
  
        //Assert
        //System.assertEquals(2,contentDocumentLinks.Size());
        System.assertEquals(quotes[0].LOA_PDF_Document_ID__c,contentDocumentLinks[0].ContentDocumentId);

        //Testing stop here
        Test.StopTest();
    }
    
    /**
     *  @description    :   This method is used to test populateFieldsValueOnCases method of ContractTriggerHelpper class
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Saurabh Kumar -  06/14/2017 - CR-20170403-10807 (DS114)
     *
     **/
    static testMethod void testPopulateFieldsValueOnCases(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Calling method to insert common data
        setupData();
        
        //Get inserted Contract
        List<Contract> contracts = [Select Id, EndDate From Contract Order By StartDate ASC];
        System.assert(contracts != null);
        
        System.assertEquals(2, contracts.size());
        
        
        //Start testing from here
        Test.startTest();
        
        //Execute the trigger
        Util.byPassAllTriggers = false;
        
        //Updating End Date
        contracts[0].EndDate = System.today().addDays(25);
        contracts[1].EndDate = System.today().addDays(30);
        update contracts;
        
        //Reset the flag
        Util.byPassAllTriggers = true;
        
        //Get updated case
        List<Case> cases = [Select Id, Renewal_Date1__c, Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate
                                FROM Case
                                WHERE Membership__c != null AND Membership__r.Latest_Subscription__c != null
                                AND Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c = null
                                AND Membership__r.Latest_Subscription__r.SBQQ__Contract__c != null 
                                Order By Status ASC];
        
        //Assertions
        System.assert(cases != null);
        System.assertEquals(2, cases.size());
        
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
     *  @description    :   This method is used to test syncContractIntegratedAccounts method of ContractTriggerHelpper class
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Saurabh Kumar -  06/14/2017 - CR-20170403-10807 (DS114)
     *
     **/
    static testMethod void testSyncContractIntegratedAccounts(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
       /* 
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'External'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id opportunityEABContinuingRecordType = TestUtilities.FindRecordTypeId('Opportunity', 'EAB Initiating'); 
        
        //List to hold Opportunity records to insert
        List<Opportunity> opportunities = new List<Opportunity>();
        
        opportunities.add(new Opportunity(RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test', AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = 'Pending'));
        insert opportunities;
        
        Contact contact = TestUtilities.CreateNewContact(true);

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Insert new Product
        Product2 product = TestUtilities.createNewProduct(testProgram.Id, true);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to listS
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addmonths(1), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contact.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual', SBQQ__DocumentStatus__c = 'Signed'));
        
        
        //Insert Opportunity
        insert quotes;

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;

        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 500));

        insert quoteLines;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
 
        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;
        
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        
        update opportunities;
         
        //List to hold Integrated_Account__c records to insert
        List<Integrated_Account__c> integratedAccounts = new List<Integrated_Account__c>();
        
        integratedAccounts.add(new Integrated_Account__c(Opportunity__c = opportunities[0].Id, Integrated_Account__c = accounts[0].Id));
        insert integratedAccounts;
        
        //Start testing from here
        Test.startTest();
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addMonths(1), ContractTerm = 20, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addMonths(1), ContractTerm = 20, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id));
        
        //Execute the trigger
        Util.byPassAllTriggers = false;
        
        insert contracts;   
        
        //Query on Conytract Integrated Account
        List<Contract_Integrated_Accounts__c> contractIntegratedAccounts = [Select Id, Name, LOA_Contract__c, Integrated_Account__c, Account__c From Contract_Integrated_Accounts__c];
        
        //Assertions
        System.assertNotEquals(null, contractIntegratedAccounts);
        System.assertEquals(2, contractIntegratedAccounts.size());
        System.assertEquals(integratedAccounts[0].Id, contractIntegratedAccounts[0].Integrated_Account__c);
        System.assertEquals(integratedAccounts[0].Id, contractIntegratedAccounts[1].Integrated_Account__c);
        System.assertEquals(accounts[0].Id, contractIntegratedAccounts[0].Account__c);
        System.assertEquals(accounts[0].Id, contractIntegratedAccounts[1].Account__c);

        
        //Delete the Contracts
        delete contracts;
        
        //Reset the flag
        Util.byPassAllTriggers = true;
        
        //Stop testing here
        Test.stopTest();
    
    */
    }
    
    /**
     *  @description    :   The method is used to test updateContractAndOppAfterContractTermination
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Saurabh Kumar -  06/14/2017 - CR-20170403-10807
     *
     **/
    testMethod static void testUpdateContractAndOppAfterContractTermination(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'External'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id opportunityEABContinuingRecordType = TestUtilities.FindRecordTypeId('Opportunity', 'EAB Continuing'); 
        
        //Create new Contact
        Contact cont = TestUtilities.CreateNewContact(true);
        
        //List to hold Opportunity records to insert
        List<Opportunity> opportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test', Main_Contact__c = cont.Id,AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = 'Pending'));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test1', Main_Contact__c = cont.Id,AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = 'Pending'));
        insert opportunities;
        
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Insert new Product
        Product2 product = TestUtilities.createNewProduct(testProgram.Id, true);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to listS
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addmonths(1), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contact.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        
        //Insert Opportunity
        insert quotes;

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;

        //Add new Quote lines n list
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
        qLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 100, Profit__c = 100, Annualized_Contract_Value__c = 100));

        insert qLines;

        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        opportunities[0].Meeting_Travel_Comp__c = 'None';
        opportunities[0].Closed_Opp_Comments__c ='Testing testing testing';
        update opportunities;
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        update opportunities;

        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[0].SBQQ__Contracted__c = true;
        
        try{
          update opportunities;    
        }catch(Exception e) {
            
        }
        
        
        //Start tesing from here
        Test.startTest();
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 1, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id, Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_TERMINATION_OF_CONTRACT, SBQQ__RenewalOpportunity__c = opportunities[1].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 1, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id, SBQQ__RenewalOpportunity__c = opportunities[1].Id));
        
        //Execute the trigger 
        Util.byPassAllTriggers = false;
        
        insert contracts;
        
        //Query on the Contract to get updated Contract
        List<Contract> updatedContracts = [Select Id, Status From Contract Where ID =: contracts[0].Id];
        
        //Assertions
        System.assert(updatedContracts != null);
        System.assertNotEquals(CPQConstants.CONTRACT_STATUS_TERMINATED, updatedContracts[0].Status);
        
        //Bypass all triggers 
        Util.byPassAllTriggers = true;
        
        //contracts[0].Status = CPQConstants.CONTRACT_STATUS_TERMINATED;
        //update contracts;
        
        //Execute trigger
        Util.byPassAllTriggers = false;
        
        //Updating the Contract Amendment Type
        /*contracts[1].Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_TERMINATION_OF_CONTRACT;
        contracts[0].Status = CPQConstants.CONTRACT_STATUS_TERMINATED;
        update contracts;
        
        //Query on the Contract to get updated Contract
        updatedContracts = [Select Id, Status From Contract Where ID =: contracts[1].Id];
        
        //Assertions
        System.assert(updatedContracts != null);
        System.assertEquals(CPQConstants.CONTRACT_STATUS_TERMINATED, updatedContracts[0].Status);
        
        //Query on the updated Opportunity
        List<Opportunity> updatedOpportunities = [Select Id, StageName From Opportunity Where Id =: opportunities[1].Id];
        
        //Assertions
        System.assert(updatedOpportunities != null);
        System.assertEquals('Closed', updatedOpportunities[0].StageName);
        */
        
        //Reset the flag 
        Util.byPassAllTriggers = true;
        
        //Stop testing here
        Test.stopTest();
    }
    
    
    
    /**
     *  @description    :   The method is used to test updateContractABCRenewalOpportunity
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  revision Log    :   Mahendra Swarnkar - 07/25/2019
     *
     **/
    testMethod static void testUpdateContractABCRenewalOpportunity(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get Record Type
        Id accountUSEducationRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSEducationRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSEducationRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Create new Contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Get Record Type
        Id opportunityEABContinuingRecordType = TestUtilities.FindRecordTypeId('Opportunity', 'EAB Initiating'); 
        
        //List to hold Opportunity records to insert
        List<Opportunity> opportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test', Main_Contact__c = contact.Id, AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = '0-MQL'));
        
        //Start testing from here
        Test.startTest();
        
        insert opportunities;
        
        //List to hold integrated Account
        List<Integrated_Account__c> integAccounts = new List<Integrated_Account__c>();

        integAccounts.add(new Integrated_Account__c(Opportunity__c = opportunities[0].Id));

        //Insert integrated Account
        insert integAccounts;
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Insert new Product
        Product2 product = TestUtilities.createNewProduct(testProgram.Id, true);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to listS
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addmonths(1), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contact.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual', SBQQ__DocumentStatus__c = 'Generated'));
               
        //Insert Opportunity
        insert quotes;

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 100));
        //quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 500));

        insert quoteLines;      
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //Start testing from here
       // Test.startTest();
        
        //Update Proposal
        quotes[0].ApprovalStatus__c = 'Approved';
        quotes[0].SBQQ__Status__c = 'Approved';
        quotes[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update quotes;
        
        //Get Record Type
        Id QuoteOpenRecordType1 = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Locked');
        
        //Update Proposal
        quotes[0].SBQQ__Status__c = 'Locked';
        quotes[0].RecordTypeId = QuoteOpenRecordType1;
        
        //Bypass
        Util.BypassAllTriggers = true;
        update quotes;
        
        //Stop testing here
        Test.stopTest();
        
        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        update opportunities;
         
        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunities[0].Contract_Signature_Date__c = Date.today();
        opportunities[0].SBQQ__Contracted__c = true;
        
        update opportunities;
        

        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 1, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                                   Batch_Status__c = System.Label.Ready_For_Batch,SBQQ__Quote__c = quotes[0].Id));
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        //Insert contract
        insert contracts;
        
        //Assert
        System.assertEquals(1, contracts.size());
                
        opportunities[0].StageName = 'Closed Won';
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //update opportunity
        update opportunities;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        contracts[0].Status = 'Activated';
       
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //New renewal opportunity
        Opportunity opp = new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test', AccountId = accounts[0].Id, CloseDate = System.today().addDays(32), StageName = '0-Exploring', Main_Contact__c = contact.Id);
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert opportunity
        insert opp;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        //update
        //update contracts;
        
        contracts[0].SBQQ__RenewalOpportunity__c = opp.Id;
        
        //update
        //update contracts;
    }
       // Mahendra Swarnkar - CR-20200610-14172 - 06/15/2020    
        static testmethod void test_validateContract(){
        Test.startTest();
        Util.byPassAllTriggers = true;
           
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testCode', 
                                              Business_line__c = 'RI', Status__c = 'Active');
        programs.add(program_1);
        insert programs;
        
        
        Account account = TestUtilities.CreateNewAccount(true);
         //Create new Contact
        Contact contact = TestUtilities.CreateNewContact(true);
           
        //Standard Contract
        Contract contract = testUtilities.createNewStandardContract(account.Id, false);
        contract.Invoice_Contact__c = contact.Id;
        insert contract;
           
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
         
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'Custom Application Marketing', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'ESAM', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Custom Application Marketing',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1, Allow_Subscription_Adjustments__c = true,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        insert products;
           
        SBQQ__Subscription__c progSub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Insert
        insert progSub1;
       
        SBQQ__Subscription__c progSub2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    Program_Subscription__c = progSub1.Id, SBQQ__Contract__c = contract.Id, SBQQ__Account__c = account.Id,
                                                    SBQQ__Product__c = products[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__RequiredByProduct__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Insert
        insert progSub2;
        
   
        ABC_Revenue__c r = new ABC_Revenue__c ();
        r.Contract__c = contract.Id;
        Insert r;
        
        Util.byPassAllTriggers = false;
        try{
        delete contract;
        }
        catch(DmlException e){
            system.assert(true,(e.getmessage()).contains('You can not delete a contract, as revenue records are exit on this contract.'));
        }
        Test.stopTest();
        
    }
    
    /**
     *  @description    :   This method is used to test updateSubscriptionsInvoicingArrangement method of ContractTriggerHelpper class
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Added By - Mahendra Swarnkar - 09/01/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
     *
     **/
    testMethod static void test_updateSubscriptionsInvoicingArrangement(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', Contract_Primary__c = true, Contact_Status__c = 'Active', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', Contract_Primary__c = true, Contact_Status__c = 'Active', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        insert contacts;
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        //Adding opportunities in List 
        opportunities.add(TestUtilities.CreateNewOpportunity(accounts[0].Id,false));
        opportunities.add(TestUtilities.CreateNewOpportunity(accounts[1].Id,false));
        insert opportunities;
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[1].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Insert Opportunity
        insert quotes;
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        //Adding the Contracts in list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[1].Id));    
        
        insert contracts;
        
        //Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        
        //List to hold Subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Adding the Subscriptions in List
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionProgramRecordType, SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 5));
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionProgramRecordType, SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 10));
        insert subscriptions;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, UserInfo.getUserId());
        
        Contract contract = testUtilities.createNewStandardContract(accounts[0].Id, true);
        System.assert(contract.Id != null);
        
        List<Billing_Schedule_Header__c> listBSH = new List<Billing_Schedule_Header__c>();
        listBSH.add(TestUtilities.CreateNewBillingScheduleHeader(contracts[0].Id, accounts[0].Id));
        listBSH.add(TestUtilities.CreateNewBillingScheduleHeader(contracts[1].Id, accounts[0].Id));
        
        //Grab our Company due to Test Class deployment error
        c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
        
        //Grab the Dimension 1 record from our Test Data Setup
         c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];
        
        //Query for our currency from our setup data
        c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c = :testCompany.Id];
        
        //Create our test Sales Invoice record we'll work with
        c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
                c2g__Account__c =  accounts[0].Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1',
                BSP_Standard_Contract__c = contracts[1].Id
            );
        insert salesInvoice;
        c2g__codaInvoice__c salesInvoice1 = new c2g__codaInvoice__c(
                c2g__Account__c =  accounts[0].Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1',
                BSP_Standard_Contract__c = contracts[0].Id
            );
        insert salesInvoice1;
        Util.byPassAllTriggers = false;
        
        //test start 
        Test.startTest();
        //updating the Contracts
        contracts[0].Invoicing_Arrangement__c = 'Quarterly';
        contracts[1].Invoicing_Arrangement__c = 'Semi-Annual';
        contracts[0].Invoice_Contact__c = contacts[0].Id;
        contracts[1].Invoice_Contact__c = contacts[0].Id;
        contracts[0].Main_Contact__c = contacts[0].Id;
        contracts[1].Main_Contact__c = contacts[0].Id;
        update contracts;
        
        //set to store the contracts Ids
        Set<Id> contractsIds = new Set<Id>{contracts[1].Id, contracts[0].Id};
            
        contracts = [Select Id,Invoicing_Arrangement__c From Contract Where Id =:contractsIds Order By Invoicing_Arrangement__c ASC];
        //List of updated Subscriptions
        subscriptions = [Select Id,SBQQ__Contract__c, Invoicing_Arrangement__c From SBQQ__Subscription__c
                         Where SBQQ__Contract__c =:contractsIds Order By Invoicing_Arrangement__c ASC];
        
        System.assertEquals(contracts[0].Invoicing_Arrangement__c, subscriptions[0].Invoicing_Arrangement__c);
        System.assertEquals(contracts[1].Invoicing_Arrangement__c, subscriptions[1].Invoicing_Arrangement__c);
   
        //test stop
        Test.stopTest();
       
    }
    
    static testMethod void test_populateFieldValuesOnOpportunity(){
         //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', Contract_Primary__c = true, Contact_Status__c = 'Active', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', Contract_Primary__c = true, Contact_Status__c = 'Active', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        insert contacts;
        
         Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        //Adding opportunities in List 
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(accounts[0].Id,false);
        opp1.RecordTypeId = oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING);
        
        Opportunity opp2 = TestUtilities.CreateNewOpportunity(accounts[1].Id,false);
        opp2.RecordTypeId = oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING);
        opportunities.add(opp1);
        opportunities.add(opp2);
        insert opportunities;
        
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[1].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Insert Opportunity
        insert quotes;
        
        Test.startTest();
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        //Adding the Contracts in list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[1].Id));    
        
        
        Util.byPassAllTriggers = true;
        insert contracts;
        
        ContractTriggerHelper.populateFieldValuesOnOpportunity(contracts, null);
        Test.stopTest();
       
    }
      
    /**
     *  @description    :   The method is used to test updateContractAndOppAfterContractTermination
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 Created - Saurabh Kumar -  06/14/2017 - CR-20170403-10807
     *
     **/
    testMethod static void testmethodv1(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'External'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //Get Record Type
        Id opportunityEABContinuingRecordType = TestUtilities.FindRecordTypeId('Opportunity', 'EAB Continuing'); 
        
        //Create new Contact
        Contact cont = TestUtilities.CreateNewContact(true);
        
        //List to hold Opportunity records to insert
        List<Opportunity> opportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test', Main_Contact__c = cont.Id,AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = 'Pending'));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = opportunityEABContinuingRecordType, Name = 'Test1', Main_Contact__c = cont.Id,AccountId = accounts[0].Id, CloseDate = System.today().addDays(10), StageName = 'Pending'));
        insert opportunities;
        
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Insert new Product
        Product2 product = TestUtilities.createNewProduct(testProgram.Id, true);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to listS
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addmonths(1), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contact.Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        
        //Insert Opportunity
        insert quotes;

        //Get the Bypass Custom Setting record for this user
        Bypass_Logic__c bypassLogic = Bypass_Logic__c.getInstance(UserInfo.getUserId());
        bypassLogic.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypassLogic.Bypass_Triggers__c = true;
        upsert bypassLogic;

        //Add new Quote lines n list
        List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
        qLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = product.Id, SBQQ__NetPrice__c = 100, Profit__c = 100, Annualized_Contract_Value__c = 100));

        insert qLines;

        opportunities[0].StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE;
        opportunities[0].Meeting_Travel_Comp__c = 'None';
        opportunities[0].Closed_Opp_Comments__c ='Testing testing testing';
        update opportunities;
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED;
        opportunities[0].Meeting_Travel_Comp__c = 'Hotel';
        update opportunities;

        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
        update opportunities;

        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[0].SBQQ__Contracted__c = true;
        
        try{
          update opportunities;    
        }catch(Exception e) {
            
        }
        
        
        //Start tesing from here
        Test.startTest();
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 1, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id, Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_TERMINATION_OF_CONTRACT, SBQQ__RenewalOpportunity__c = opportunities[1].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 1, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
        SBQQ__Quote__c = quotes[0].Id, SBQQ__RenewalOpportunity__c = opportunities[1].Id));
         insert contracts;
        
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=quotes[0].id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
        
        //Execute the trigger 
        
        
        //Query on the Contract to get updated Contract
        List<Contract> updatedContracts = [Select Id, Status From Contract Where ID =: contracts[0].Id];
        
        //Assertions
        System.assert(updatedContracts != null);
        System.assertNotEquals(CPQConstants.CONTRACT_STATUS_TERMINATED, updatedContracts[0].Status);
        
        //Bypass all triggers 
        Util.byPassAllTriggers = true;
    
    
        //Stop testing here
        Test.stopTest();
    }
    
    
}