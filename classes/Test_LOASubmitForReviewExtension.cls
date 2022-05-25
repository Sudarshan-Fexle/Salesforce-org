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
 /**
  *   Purpose         :     Test class for LOASubmitForReviewExtension
  *            
  *   Create By       :     Subhash Garhwal  
  * 
  *   Created Date    :     05/8/2014
  *
  *   Revision Log    :     V_1.0 - Created
  *			    V_1.1 - Modified By - Deepak Kumar - 07/12/2017 - Q2C Release based changes
  *			    V_1.2 - Modified By - Victor Hanson - 08/22/2017 - Q2C Post Silent Deployment changes
  *			    V_1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
  *   Coverage        :     
  **/
@isTest(seeAllData=false)
private class Test_LOASubmitForReviewExtension {
	
    //nickname for the quote
    public static string quoteNickname = 'quote_1337';
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    
    /**
     * 
     * @description: Setup the test data
     * 
     * @revision log: V1.0 - 08/21/2017 - Created - Victor Hanson
     * 
     **/
    @testSetup static void setup() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create a new Contact record
        Contact primaryContact = TestUtilities.createNewContact(account, true);
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Continuing' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_CONTINUING;
        opportunity.StageName = CPQConstants.OPPORTUNITY_STAGE_ORIGINATION;
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Calling method to insert ContentVersion
        ContentVersion conVersion = new ContentVersion(Title='LOA1',
                                                       PathOnClient='/LOA1.docx',
                                                       origin = 'H',
                                                       VersionData=Blob.valueOf('Unit Test ContentVersion Body'));
        insert conVersion;
        System.assert(conVersion.Id != null);
        
        //get the content document id
        conVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVersion.Id];
        System.assert(conVersion.ContentDocumentId != null);
        
        //List to hold quote records
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        quote = TestUtilities.createNewSbqqQuote(false);
        quote.Nickname__c = quoteNickname;
        quote.SBQQ__PrimaryContact__c = primaryContact.Id;
        quote.SBQQ__DocumentStatus__c = 'Pending';
        quote.LOA_PDF_Document_ID__c = conVersion.ContentDocumentId;
        quote.LOA_Word_Document_ID__c = conVersion.ContentDocumentId;
        quote.Proposal_Version__c = null;
        quote.LOA_Document_Version__c = '11';
        quote.SBQQ__StartDate__c = System.today().addDays(-5);
        quote.SBQQ__SubscriptionTerm__c = 12;
        quotes.add(quote);
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //inserting quote records
        insert quotes;
    }
    
    /**
     * 
	 *	@description	:	test the Submit method to send LOA Document for redline 
	 *
	 *	@revision Log	:	V1.0 - 08/21/2017 - Created - Victor Hanson 
     * 
     **/
    static testmethod void testSubmit() {
        
	// Modified By - Rajeev Jain - 09/03/2020 - CR-20200217-13763
        //get the proposal
        SBQQ__Quote__c quote = [SELECT Id, OwnerId, Owner.Name, Owner.Email, External_Review_Due_Date__c, SBQQ__Status__c, LOA_PDF_Document_ID__c, LOA_Word_Document_ID__c,
                                Redline_Approver__c, SBQQ__SalesRep__r.Name, SBQQ__SalesRep__r.Email
                                FROM SBQQ__Quote__c WHERE Nickname__c = :quoteNickname];
        
        //set the expiration date
        quote.External_Review_Due_Date__c = Date.today().addDays(2);
        
        quote.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_APPROVED;
        
        //Initialize mock response
        Test.setMock(HttpCalloutMock.class, new SpringCMMockResponseGenerator());
        //HttpService.response = mockService.respond(httpReq);
        
        //set the page reference
        PageReference pageRef = Page.LOASubmitForReview;
        test.setCurrentPage(pageRef);
        
        //pass url params
        ApexPages.currentPage().getParameters().put('Type', LOASubmitForReviewExtension.SUBMISSION_TYPE_REDLINE);
        
        //instantiate the controller
        LOASubmitForReviewExtension controller = new LOASubmitForReviewExtension(new ApexPages.standardController(quote));
        
        //set the recipient to the current owner
        controller.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_PROPOSAL_OWNER;
        
        Test.startTest();
        
        //execute callouts even though this is a test method
        HTTPService.sendCalloutInUnitTest = true;
        
        //submit
        controller.submit();
        Test.stopTest();
        
        system.assertEquals(LOASubmitForReviewExtension.RADIO_OPTION_PROPOSAL_OWNER, controller.redlineRecipient);
        system.assertEquals(LOASubmitForReviewExtension.SUBMISSION_TYPE_REDLINE, controller.submissionType);
        
        //verify that no error occurred
        system.assertEquals(new list<ApexPages.Message>{new ApexPages.message(ApexPages.severity.CONFIRM,'Submitted for Redline')}, ApexPages.getMessages());
        system.assertEquals(true, controller.isSucceed);
    }
    
    /**
     * 
	 *	@description	:	test the 'SetReviewerNameAndEmail' method, to verify the name/email are set properly for the various options.
	 *
	 *	@revision Log	:	V1.0 - 08/21/2017 - Created - Victor Hanson 
	 *
	 **/
    static testMethod void testSetReviewerNameAndEmail() {
        
        // Modified By - Rajeev Jain - 09/03/2020 - CR-20200217-13763
        //get the proposal
        SBQQ__Quote__c quote = [SELECT Id, OwnerId, Owner.Name, Owner.Email, External_Review_Due_Date__c, SBQQ__Status__c, SBQQ__SalesRep__r.Name, SBQQ__SalesRep__r.Email,
                                LOA_PDF_Document_ID__c, LOA_Word_Document_ID__c, Redline_Approver__c, SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email
                                FROM SBQQ__Quote__c WHERE Nickname__c = :quoteNickname];
        
        //set the expiration date
        quote.External_Review_Due_Date__c = Date.today().addDays(2);
        
        quote.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_APPROVED;
        
        //Initialize mock response
        Test.setMock(HttpCalloutMock.class, new SpringCMMockResponseGenerator());
        //HttpService.response = mockService.respond(httpReq);
        
        //set the page reference
        PageReference pageRef = Page.LOASubmitForReview;
        test.setCurrentPage(pageRef);
        
        //pass url params
        ApexPages.currentPage().getParameters().put('Type', LOASubmitForReviewExtension.SUBMISSION_TYPE_REDLINE);
        
        //instantiate the controller
        LOASubmitForReviewExtension controller = new LOASubmitForReviewExtension(new ApexPages.standardController(quote));
        
        //set the recipient to the primary contact
        controller.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_PRIMARY_CONTACT;
        controller.setReviewerNameAndEmail();
        system.assertEquals(quote.SBQQ__PrimaryContact__r.Email, controller.proposal.Redline_Recipient_Email__c);
        
        //set the recipient to the current owner
        controller.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_PROPOSAL_OWNER;
        controller.setReviewerNameAndEmail();
        system.assertEquals(quote.Owner.Email, controller.proposal.Redline_Recipient_Email__c);
        
        //set the recipient to DealDesk
        controller.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_DEAL_DESK;
        controller.setReviewerNameAndEmail();
        system.assertEquals(Label.Proposal_Redline_DealDesk, controller.proposal.Redline_Recipient_Email__c);
        
        //set the recipient to Legal
        controller.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_LEGAL;
        controller.setReviewerNameAndEmail();
        system.assertEquals(Label.Proposal_Redline_Legal, controller.proposal.Redline_Recipient_Email__c);
    }
    
    
	//Test SpringCM functionality
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
        						  ProductCode = 'RIPRO'));
		
		//Insert
		insert products;
		
        //Parent Opportunity
    	List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
    										 AND Name =: CPQConstants.OPP_RECORD_TYPE_NAME_EAB_INITIATING  ORDER BY DeveloperName];
    	
    	//Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List to hold Contact
		List<Contact> contacts = new List<Contact>();

        //Addd to list
        contacts.add(new Contact( AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));

        //Insert Contact
        insert contacts;
        
    	//List of Opportunity for Test 
    	List<Opportunity> parentOpportunities = new List<Opportunity>();
    	//Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    	//Add Parent (Contract LOA) opportunities in list
    	parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', Main_Contact__c = contacts[0].Id, AccountId = acc.Id, StageName = 'On Deck', CloseDate = System.today(),
    	                                        RecordTypeId = recordTypes[0].Id));
		
    	//Set Opportunity flag
        Util.BypassAllTriggers = true;
       
    	//Insert List of Opportunity
        insert parentOpportunities;
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Pending', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id, SBQQ__PrimaryContact__c = contacts[0].Id));        
        
        //Set trigger flags
   		Util.BypassAllTriggers = true;
   		
        //Insert list of Quote
        insert quotes;
        
        //List of content versions
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        versionDoc.FirstPublishLocationID = UserInfo.getUserId();
        
        //Insert Version Doc
        insert versionDoc;
        
        //SOQL through the Content Version to get the Document Id
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        //Get Content Document
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id =: versionDocs[0].ContentDocumentId];
        
        //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = quotes[0].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
        
       //Update Proposal with Document Id
        quotes[0].LOA_Word_Document_ID__c = contDoc[0].Id;
        
        //Update
        update quotes;
        
        //Object for APexStandardController
		ApexPages.StandardController sC = new ApexPages.standardController(quotes[0]);
		
        //Start Testing
        Test.startTest();
        
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Type', 'Redline');
        
        //Contructor
        LOASubmitForReviewExtension lOASubmitRevew = new LOASubmitForReviewExtension(sC);
        
        
        
        //try - Catch
        try {
	
			//Call controller Method
	        lOASubmitRevew.submit();

		} catch(Exception e) {

			//Assert    
            String errormessage = e.getMessage();
            System.assert(errormessage.contains('Expiration Date must be greater than today.'));
        
		}
		
		//Reiniliation the controller 
		lOASubmitRevew = new LOASubmitForReviewExtension(sC);
        lOASubmitRevew.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_DEAL_DESK;
        
		Date todayDate = Date.today();
		
		quotes[0].External_Review_Due_Date__c = todayDate.addDays(2);
		update quotes;
		
		//try - Catch
		try {
			
			//
			//lOASubmitRevew.redlineApprover = 'Deal Desk';
			
		   //Call controller Method
	       pageReference pgRefer  = lOASubmitRevew.submit();
	       
	       
		} catch(Exception e) {

			//Assert    
            String errormessage = e.getMessage();
            		System.debug('****************'+errorMessage);
        
		}
				
		//Reiniliation the controller 
		lOASubmitRevew = new LOASubmitForReviewExtension(sC);
        lOASubmitRevew.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_PROPOSAL_OWNER;
		
		//quote 
		quotes[0].LOA_Word_Document_ID__c = '';
		update quotes;
		
		//try - Catch
		try {
			
			//Call controller Method
	        lOASubmitRevew.submit();
			
		} catch(Exception ex) {
			
			//Assert    
            String errormessage = ex.getMessage();
            System.assert(errormessage.contains('Proposal should have correct LOA Word Document Id'));
		
		}
		
		//Reiniliation the controller 
		lOASubmitRevew = new LOASubmitForReviewExtension(sC);
        lOASubmitRevew.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_LEGAL;
		
		//Update Proposal with Document Id
        quotes[0].LOA_Word_Document_ID__c = contDoc[0].Id;
        quotes[0].External_Review_Due_Date__c = todayDate.addDays(7);
        update quotes;
		
		//try - Catch
		try {
			
			//Call controller Method
	        lOASubmitRevew.submit();
			
		} catch(Exception ex) {
			
			//Assert    
            String errormessage = ex.getMessage();
		
		}
		
        
		 //List of Quote   
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Approved', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id,
        							  SBQQ__PrimaryContact__c = contacts[0].Id, External_Review_Due_Date__c = date.Today().addDays(2), LOA_Word_Document_ID__c = contDoc[0].Id));
        
        //Set trigger flags
   		Util.BypassAllTriggers = true;
   		
		//Inserting new proposal
        insert proposals;
        
       
        //Object for APexStandardController
		ApexPages.StandardController sC1 = new ApexPages.standardController(proposals[0]);     
		
		 //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Type', 'Redline');
        
        
		//Reiniliation the controller 
		LOASubmitForReviewExtension lOASubmitRevew1 = new LOASubmitForReviewExtension(sC1);
		
		lOASubmitRevew1.redlineRecipient = LOASubmitForReviewExtension.RADIO_OPTION_DEAL_DESK;
		//lOASubmitRevew1.redlineApprover = 'Deal Desk';
		
		system.debug('Hello everyone2222');
			
		
		//try - Catch
		try {
			
			//Call controller Method
	        lOASubmitRevew1.submit();
			
		} catch(Exception ex) {
			
			//Assert    
            String errormessage = ex.getMessage();
            System.assert(errormessage.contains('Proposal should have correct LOA Word Document Id'));
		
		} 	
		
		//Stop Testing
        Test.stopTest();
        
    }
}