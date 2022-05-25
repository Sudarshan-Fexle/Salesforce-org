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
@isTest(seeAllData=false)
public class Test_ContentVersionTriggerHelper {
    
    /**
     *  Purpose         :   Test class for ContentVersionTriggerHelper
     *               
     *  Created By      :   Abhinav Sharma
     *   
     *  Created Date    :   09/03/2016
     *   
     *  Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20160224-9640
     *                       
     *  Coverage        :   v_1.0 - ContentVersionTriggerHelper - 100%
    **/
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640 - Method to Setup Common data in test class
    @testSetup static void setUpTestData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Querying Details for record type on Site_Issue__c Object
        List<RecordType> issueRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Site_Issue__c' 
                                        AND IsActive = true 
                                        AND DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST
                                        ORDER By DeveloperName ASC];
        
        //List to hold the case records
        List<Site_Issue__c> issues = new List<Site_Issue__c>();
        
        //Create a sample case record to insert and test case trigger
        issues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test description', Data_Load_Type__c = 'Current',
                                     Data_Load_Period_Begin__c	= System.today(), Data_Load_Period_End__c = System.today(),
                                     RecordTypeId = issueRdTypes[0].Id));
        
        //Insert
        insert issues;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName = 'EAB_Custom'
                                        ORDER By DeveloperName ASC];
                                        
                                        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', Member_Support_Ticket__c =  issues[0].Id,
                                Description = 'Test', AccountId = accounts[0].Id);
       
        //Populating list with case records
        cases.add(aCase_1);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Insert cases
        insert cases;
        
        //This setup records are for method:- testGrantPublicSharingOnFilesForCPQExceptionRequest
        //Bypass Flags
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
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640
    //This method test sharing of the files on the Member Support, Attachment of the file on MS, when file stamp on the case record
    static testmethod void testSharingFilesFromCaseToMemberSupportObj() {
        
        //Query on Case Records
        List<Case> cases = [select Id, RecordTypeId, Description, Origin, AccountId , Member_Support_Ticket__c from Case];
        
        //Start test from here
        Test.startTest();
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Now Assert for Results
        System.assertEquals(true,cases[0].Member_Support_Ticket__c != null);
              
        //Insert File On Case Object and See Attachment on the Case and See Sharing of the files on the Memeber Support and Check attachment as well
        //List of content versions
         
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
         //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = cases[0].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
         
        //now uu
        //Query on Memeber Support Records and see if the file is visible below of the Member Support
        List<Site_Issue__c> issues = [select Id from Site_Issue__c where Id = :cases[0].Member_Support_Ticket__c];
        
        System.assertEquals(true, issues.size() > 0);
        
        //Stop Test
        Test.stopTest();
        
        //============ Since ContentVersion Library works as Webservice, so we have to wait for those asserts, in order to check correct results===========
        //Now convert member Support Id to LinkEntity Id
        String linkEntityID = issues[0].Id;
        
        //Now Query on Content Document Link if it is inserted for Member Support Record on the case object
        List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //Assert to check if Document file inserted on Case record, has stamped on Parent Member Support Reocrd
        //System.assertEquals(true, documentLink.size() > 0);
        //System.assertEquals(true,documentLink[0].ContentDocumentId == contDoc[0].Id);
        
        //Qeury to Get Attachment on case's Record
        //When any file insert on Case record that must be shared with corrosponding Member Support record, 
        //along with this that file must be stamped as attachment, just below of the Case recod
        List<Attachment> attachmentList = [select Id, ParentId, body, Name, ContentType from Attachment where ParentId = :cases[0].Id];
        
        //System.assertEquals(true, attachmentList.size() > 0);
        //System.assertEquals(true,attachmentList[0].Name == contDoc[0].Title);
    }
    
    //Added By - Rajeev Jain - 09/09/2016 - CR-20160224-9640
    //This method test sharing of the files on the Member Support, Attachment of the file on MS, when file stamp on the case record
    static testmethod void testSharingFilesFromMemberSupportObjToCase() {
        
        //Query on Case Records
        List<Case> cases = [select Id, RecordTypeId, Description, Origin, AccountId , Member_Support_Ticket__c from Case];
        
        //Start test from here
        Test.startTest();
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Now Assert for Results
        System.assertEquals(true,cases[0].Member_Support_Ticket__c != null);
              
        //Insert File On Case Object and See Attachment on the Case and See Sharing of the files on the Memeber Support and Check attachment as well
        //List of content versions
         
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
        //Assert
        System.assert(true, contDoc.size()>0);
        
        //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = cases[0].Member_Support_Ticket__c;
        contDocLink.ShareType = 'V';
        insert contDocLink;
         
        //now uu
        //Query on Memeber Support Records and see if the file is visible below of the Member Support
        List<Site_Issue__c> issues = [select Id from Site_Issue__c where Id = :cases[0].Member_Support_Ticket__c];
        
        System.assertEquals(true, issues.size() > 0);
        
        //Stop Test
        Test.stopTest();    
        
        //============ Since ContentVersion Library works as Webservice, so we have to wait for those asserts, in order to check correct results===========
        //Now convert Case Id to LinkEntity Id
        String linkEntityID = cases[0].Id;
        
        //Now Query on Content Document Link if it is inserted for Case Record on the Member Support Record
        List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //Assert to check if Document file inserted on Ms record, has stamped on Child Case Record
        //System.assertEquals(true, documentLink.size() > 0);
        //System.assertEquals(true,documentLink[0].ContentDocumentId == contDoc[0].Id);
        
        //Qeury to Get Attachment on Ms Record
        //When any file insert on Ms that must be shared with corrosponding Case record, 
        //along with this that file must be stamped as attachment, just below of the Ms recod
        List<Attachment> attachmentList = [select Id, ParentId, body, Name, ContentType from Attachment where ParentId = :cases[0].Member_Support_Ticket__c];
        
        //System.assertEquals(true, attachmentList.size() > 0);
        //System.assertEquals(true,attachmentList[0].Name == contDoc[0].Title);
    }
    
    
    //Added By - Mahendra Swarnkar - 06/17/2019 
    static testmethod void testGrantPublicSharingOnFilesForCPQExceptionRequest() {
        
        Util.byPassAllTriggers = true;
        
        //Get Account
      	List<Account> accounts = [Select Id From Account order By Name];
      
      	//Assert
      	System.assertEquals(3, accounts.size());
      
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
        
        //List of Contract Exception.
      	List<CPQ_Exception_Request__c> exceptionRequests = new List<CPQ_Exception_Request__c>();
        
        //Add new contractException.
        exceptionRequests.add(new CPQ_Exception_Request__c( Proposal__c = proposals[0].Id, 	Status__c = 'Draft'));
        
        //Insert
        insert exceptionRequests;
        
        Util.BypassAllTriggers = false;
        
        //Stop Test
        Test.startTest();
        
        //Insert File On CPQ Exception Request Object
        //List of content versions
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
         //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = exceptionRequests[0].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
        
        //Stop Test
        Test.stopTest();
        
        String linkEntityID1 = exceptionRequests[0].Id;
        List<ContentDocumentLink> cdocumentLink = [select Id, ContentDocumentId, LinkedEntityId, LinkedEntity.type from ContentDocumentLink where LinkedEntityId =: linkEntityID1];
        system.debug('@@@@@@@@' +cdocumentLink);
        System.assertEquals(1, cdocumentLink.size());
        System.assertEquals('CPQ_Exception_Request__c', cdocumentLink[0].LinkedEntity.type);
        
        //List to hold the ContentDistribution records to be insert
        List<ContentDistribution> listContentDistributions = new List<ContentDistribution>();
        
        //Populate the list
        listContentDistributions.add(new ContentDistribution(ContentVersionId = versionDoc.id, Name = 'Test', PreferencesAllowViewInBrowser = true, 
                                                                                 	PreferencesLinkLatestVersion = true, PreferencesNotifyOnVisit = false,
                                                                                 	PreferencesPasswordRequired = false, PreferencesAllowOriginalDownload = true));
        
        String linkEntityID = exceptionRequests[0].Id;
        
        //Now Query on Content Document Link if it is inserted for CPQ Exception Request.
        List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //Assert to check if Document file inserted on Ms record, has stamped on Child Case Record
        System.assertEquals(true, documentLink.size() > 0);
        System.assertEquals(true,documentLink[0].ContentDocumentId == contDoc[0].Id);
    }
	//Added By - Mahendra Swarnkar - 06/24/2020
	static testmethod void testDataUpdateSteps() {
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        //Assert
        System.assertEquals(3, accounts.size());
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
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-Exploring';
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
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        Util.BypassAllTriggers = true;
        //Insert list of Quote
        insert proposals;
        //Insert File On CPQ Exception Request Object
        //List of content versions
        ContentVersion versionDoc = new ContentVersion(Title = 'OrderForm_Q-95889', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        Test.startTest();
        insert versionDoc;
        Test.stopTest();
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
         //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = proposals[0].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
        ContentVersionTriggerHelper.dataUpdateSteps('EAB Integration Sharing', false );
        ContentVersionTriggerHelper.dataUpdateSteps('Export LOA Missmatch', false );
    }
}