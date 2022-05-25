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
@isTest(seeAllData = false)
private class Test_BatchUpdateContrctExceptionTemplate {

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

    }
    
    //Test method
    static testMethod void myUnitTest() {
      
		//Get Account
      	List<Account> accounts = [Select Id From Account order By Name];
      
      	//Assert
      	System.assertEquals(2, accounts.size());
      
      	//Get Contact
      	List<Contact> contacts = [Select Id From Contact];
      
      	//Assert
      	System.assertEquals(1, contacts.size());
      
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
      	eABInitOpp.CloseDate = System.today().addDays(1);
      	eABInitOpp.StageName = 'Prospact';
        eABInitOpp.Main_Contact__c = contacts[0].Id;
      
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
                                      SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
                                      
      	Util.BypassAllTriggers = true;
        
      	//Insert list of Quote
      	insert proposals;
      	
      	//Parent Exception template.
      	Exception_Template__c parentExceptionTemplate = new Exception_Template__c(Alternative_Language__c = 'Alternative lang', Alternative_Language_Header__c = 'Alternative lang header', 
      																			  Section__c = '1', Section_Name__c = 'sName', Version__c = 1);
      	
      	//Insert																		  
		insert parentExceptionTemplate;
        
        //Set to Hold the Master Exception Templates Ids
    	Set<Id> setMasterExceptionIds = new Set<Id>();
        setMasterExceptionIds.add(parentExceptionTemplate.Id);
        
        //Assert
        system.assertEquals(1, setMasterExceptionIds.size());
		
		//List of child Exception template.
		List<Exception_Template__c> exceptionTemplates = new List<Exception_Template__c>();
		
		//Add new Exception template record in list.
		exceptionTemplates.add(new Exception_Template__c(Alternative_Language__c = 'Alternative lang', Alternative_Language_Header__c = 'Alternative lang header', 
														 Section__c = '1', Section_Name__c = 'sName', Version__c = 1, 
														 Parent_Template__c = parentExceptionTemplate.Id ));
														 
		//Add new Exception template record in list.
		exceptionTemplates.add(new Exception_Template__c(Alternative_Language__c = 'Alternative lang', Alternative_Language_Header__c = 'Alternative lang header', 
														 Section__c = '1', Section_Name__c = 'sNameNew', Version__c = 1, 
														 Parent_Template__c = parentExceptionTemplate.Id ));
		
		//Insert												 
		insert exceptionTemplates;
        
      	//List of Contract Exception.
      	List<CPQ_Contract_Exception__c> contractExceptions = new List<CPQ_Contract_Exception__c>();
      	
      	//Add new proposal record in list
        contractExceptions.add(new CPQ_Contract_Exception__c( Proposal__c = proposals[0].Id, Exception_Template__c =  exceptionTemplates[0].Id, Order__c = 2));
        
        //Insert
        insert contractExceptions;
        
        //List of Contract Exception.
      	List<CPQ_Exception_Request__c> exceptionRequests = new List<CPQ_Exception_Request__c>();
        
        //Add new contractException.
        exceptionRequests.add(new CPQ_Exception_Request__c( Proposal__c = proposals[0].Id, 	Status__c = 'Draft'));
        
        //Insert
        insert exceptionRequests;
        
        //Start test
        Test.startTest();

            BatchUpdateContractExceptionTemplate testBatch = new BatchUpdateContractExceptionTemplate (setMasterExceptionIds);
            DataBase.executeBatch(testBatch); 
        
        //Stop test
        Test.stopTest();
        
    }
}