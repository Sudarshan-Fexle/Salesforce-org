//Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035   
@isTest(seeAllData = false)
public class Test_Batch_Update_Membership_JoinDate {
	
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
    static testMethod void myUnitTest1() {
    	
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
    	List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
    	
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
    	
    	//SOQL over the opportunity Record Type
    	List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
    	
    	//Insert Opportunity
    	Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
    	eABInitOpp.RecordTypeId = oppRTypes[0].Id;
    	eABInitOpp.AccountId = accounts[0].Id;
    	eABInitOpp.Name = 'Sub Test Opp';
    	eABInitOpp.CloseDate = System.today().addMonths(1);
    	eABInitOpp.StageName = 'Prospact';
    	
    	//ByPass all triggers
        Util.byPassAllTriggers = true;
        
    	//Insert
    	insert eABInitOpp;
    	
    	//SOQL over the Proposal record types
    	List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
    	
    	//List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
    	//Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contacts[0].Id,
                                      SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(), RecordTypeId = proposalRTypes[0].Id,
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
                                      
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
        															 SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
        															 SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
		
		Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
    	
    	subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
		
		//Add Trevel Fee products
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		//Add Trevel Fee products
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
    	
    	subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
		
		//Bypass
		Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert subProposalLines;
		
		//Update Proposal
		proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        //Bypass
		Util.BypassAllTriggers = true;
		
        update proposals;
        
        //Update Proposal
		proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        //Bypass
		Util.BypassAllTriggers = true;
		
        update proposals;
    	
    	//Update Opportunity
 		eABInitOpp.StageName = 'Contract Received - Send to Finance';
 		eABInitOpp.Contract_Signature_Date__c = System.today();

		//Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
		Util.BypassAllTriggers = false;
		
        update eABInitOpp;

		//Stop Testing here
        Test.stopTest();

        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        programSubscriptions[0].Join_Date__c = Date.today();
        
        update programSubscriptions;
        
		List<Contract>  contracts = [Select Id From Contract];

		//List to hold Contract ABC
		List<Contract__c> contractABCs = [Select Id From Contract__c];

        contractABCs[0].Join_Date__c = Date.today();
        contractABCs[1].Join_Date__c = Date.today();
        
        update contractABCs;
		
		//Get IBNS
		List<Invoice_Billing_Schedule__c> invoices = [Select Id From Invoice_Billing_Schedule__c];
        
        //Assert
        System.assertEquals(1, invoices.size());
		
		//List to hold Line item schedule
        List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();

		//Add record to list
        listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABCs[0].Id, Invoice_Billing_Schedule_del__c = invoices[0].Id, 
                        						Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                Amount__c = 20,Program_Subscription__c = programSubscriptions[0].Id));

 		//Bypass
		Util.BypassAllTriggers = true;

		//Insert Line Item Schedule test data
        insert listLIS;

        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
    
        //List to hold User
        List<User> users = new List<User>();        
    
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                                TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        //Add user record to user
        users.add(new User(Alias = 'ABC', Email = 'testuserABC@testorg.com', 
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                                TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));

 		//Bypass
		Util.BypassAllTriggers = true;

        //Insert User
        insert users;

		//List to hold membership
        List<Membership__c> memberships = new List<Membership__c>();

        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //Add record to list    
        memberships.add(new Membership__c(Name = 'Testing', /*Value_Management_Director__c = users[0].Id , Value_Management_Lead__c = users[0].Id,*/
                                        Program__c = programs[0].Id, Earliest_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                        Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                        Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id, Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

 		//Bypass
		Util.BypassAllTriggers = true;

		//Insert Membership
        insert memberships;
        
        //Executin Batch 
        Batch_Update_Membership_JoinDate b = new Batch_Update_Membership_JoinDate();
        
		Database.executeBatch(b, 20);
    }
    
    //Test method
    static testMethod void myUnitTest2() {
    	
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
    	List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
    	
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
    	
    	//SOQL over the opportunity Record Type
    	List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
    	
    	//Insert Opportunity
    	Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
    	eABInitOpp.RecordTypeId = oppRTypes[0].Id;
    	eABInitOpp.AccountId = accounts[0].Id;
    	eABInitOpp.Name = 'Sub Test Opp';
    	eABInitOpp.CloseDate = System.today().addMonths(1);
    	eABInitOpp.StageName = '0-MQL';
    	
    	//ByPass all triggers
        Util.byPassAllTriggers = true;
        
    	//Insert
    	insert eABInitOpp;
    	
    	//SOQL over the Proposal record types
    	List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
    	
    	//List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
    	//Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contacts[0].Id,
                                      SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(), RecordTypeId = proposalRTypes[0].Id,
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
                                      
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
        															 SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
        															 SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
		
		Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
    	
    	subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
        															 SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
        															 Program_or_Component__c = 'Annual Fee',
        															 SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
		
		//Add Trevel Fee products
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		//Add Trevel Fee products
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
		
		subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
    	
    	subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
        															 SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
        															 SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
        															 Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
        															 SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
        															 SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
        															 Program_or_Component__c = 'Travel Fee',
        															 SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
		
		//Bypass
		Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert subProposalLines;
		
		//Update Proposal
		proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        //Bypass
		Util.BypassAllTriggers = true;
		
        update proposals;
        
        //Update Proposal
		proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        //Bypass
		Util.BypassAllTriggers = true;
		
        update proposals;
    	
    	//Update Opportunity
 		eABInitOpp.StageName = 'Contract Received - Send to Finance';
		eABInitOpp.Contract_Signature_Date__c = System.today();
		
		//Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
		Util.BypassAllTriggers = false;
		
        update eABInitOpp;

		//Stop Testing here
        Test.stopTest();

        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        programSubscriptions[0].Join_Date__c = Date.today();
        
        update programSubscriptions;
        
		List<Contract>  contracts = [Select Id From Contract];

		//List to hold Contract ABC
		List<Contract__c> contractABCs = [Select Id From Contract__c];

        contractABCs[0].Join_Date__c = Date.today();
        contractABCs[1].Join_Date__c = Date.today();
        
        update contractABCs;
		
		//Get IBNS
		List<Invoice_Billing_Schedule__c> invoices = [Select Id From Invoice_Billing_Schedule__c];
        
        //Assert
        System.assertEquals(1, invoices.size());
		
		//List to hold Line item schedule
        List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();

		//Add record to list
        listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABCs[0].Id, Invoice_Billing_Schedule_del__c = invoices[0].Id, 
                        						Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                                Amount__c = 20,Program_Subscription__c = programSubscriptions[0].Id));

 		//Bypass
		Util.BypassAllTriggers = true;

		//Insert Line Item Schedule test data
        insert listLIS;

        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
    
        //List to hold User
        List<User> users = new List<User>();        
    
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                                TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        //Add user record to user
        users.add(new User(Alias = 'ABC', Email = 'testuserABC@testorg.com', 
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                                TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));

 		//Bypass
		Util.BypassAllTriggers = true;

        //Insert User
        insert users;

		//List to hold membership
        List<Membership__c> memberships = new List<Membership__c>();

        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //Add record to list    
        memberships.add(new Membership__c(Name = 'Testing', /*Value_Management_Director__c = users[0].Id , Value_Management_Lead__c = users[0].Id,*/
                                        Program__c = programs[0].Id, Earliest_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                        Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                        Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id, Account_Name__c = accounts[0].Id,
                                        Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                        Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
                                        Delivery_Manager__c = contacts[0].Id*/));

 		//Bypass
		Util.BypassAllTriggers = true;

		//Insert Membership
        insert memberships;
        
        //Executin Batch 
		Batch_Memberships b3 = new Batch_Memberships();
        
		Database.executeBatch(b3, 200);
    }
}