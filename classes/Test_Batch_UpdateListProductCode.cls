@isTest(seeAllData = false)
public class Test_Batch_UpdateListProductCode {
    
    @testSetup static void dataSetup() {
        
        // TO DO: implement unit test
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[0].Status__c = 'Active';
        programs[0].Name = 'TMBH - Test Method';
        programs[0].Program_Acronym__c = 'TMBH';
        programs[0].Program_Formal_Name__c = 'Test Method';
        programs[0].Renewable__c = true; 
        programs[0].New_Business_Business__c = 'EAB';
        programs[0].Type__c = 'Standard';
        programs[0].Type__c = 'Standard';
        programs[0].New_Business_Vertical__c = 'EAB';
        programs[0].Entity__c = 'EAB';
        programs[0].Program_Line__c = 'PT';
        programs[0].Sector__c = 'HE';
        programs[0].Applicable_Segments__c = 'International Education;US Education';
        programs[0].Solomon_Code__c = '851';
        programs[0].New_Business_Marketer__c = 'HE SSC';
        programs[0].Create_memberships__c = 'Yes';
        programs[0].Renewal_Unit_Count__c = 1;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Travel Fee', IsActive = true, ProductCode = 'TravelFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Travel Fee', Program_Name_Member_Facing__c = 'Travel Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Offer', IsActive = true, ProductCode = 'Offer', SBQQ__Component__c = true,Offer__c = true,
                                  Product_Category__c = 'Offer', Program_Name_Member_Facing__c = 'Offer',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Trevel Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Offer', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[3].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert productOptions;
        
        //Account
        Account acc = new Account(Name = 'Test AAccount');
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert acc;
        
        //Account
        Account account = new Account(Name = 'Test BAccount');
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert account;
        
        //SOQL over the opportunity Record Type
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = acc.Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert contact;
        
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = acc.Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert IBS
        insert invoices;
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Add record to list
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = acc.Id,
                                       Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Year with Opt Out'));
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = acc.Id,
                                       Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Fixed Term'));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert the contract ABC
        insert contracts;
        
        //Creating new Custom setting Data 
        List<Sync_Field__c> syncFields = new List<Sync_Field__c>();
        syncFields.add(new Sync_Field__c(Name = 'Test', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Program', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        syncFields.add(new Sync_Field__c(Name = 'Test1', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Component', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        
        insert syncFields;
    }
    
    //Test method
    static testMethod void testBatch() {
        
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        
        //Assert
        System.assertEquals(1, contracts.size());  
        
        List<Membership__c> memberships = [select id from membership__c];
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName = 'Program' AND IsActive = true];
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> Programsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        Programsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id,
                                                           SBQQ__Quantity__c = 1,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));                                                     
        //Insert
        insert Programsubscriptions;
        
        
        Database.executeBatch(new Batch_UpdateListProductCode());    
        
        Test.stopTest();
        //Get Program subscriptiio
        programSubscriptions = [Select Id, SBQQ__Contract__c,Product_Code__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program']; 
        contracts = [Select Id, List_Of_Product_Codes__c From Contract Where Id =: programSubscriptions[0].SBQQ__Contract__c];
        
        //assert
        System.assertEquals(programSubscriptions[0].Product_Code__c, contracts[0].List_Of_Product_Codes__c);
    }
}