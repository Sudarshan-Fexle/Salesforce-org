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
private class Test_ProposalCloneController {
/**
  *   Purpose         :   Test class for ProposalCloneController, Clone Proposal If Contract Status is draft/Approved 
  *            
  *   Create By       :   Deepak Kumar
  * 
  *   Created Date    :   07/07/2017
  *
  *   Revision Log    :   V_1.0 - Created -Deepak Kumar - CR-20170403-10807 
  *                       
  * 
  *   Coverage        :   V_1.0 - 
**/
    
    
    //This method is used to test the clone proposal functionality on the proposal record
    static testMethod void testDoCloneProposal() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //ByPass all the triggers
        Util.byPassAllTriggers = true;
        
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
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
        						  ProductCode = 'RIPRO'));
		
		products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
        						  ProductCode = 'PTPRO'));
		
		//Insert
		insert products;
        
        //Create the opportunity record 
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        //List to hold the Proposal record 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Accepted', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Approved', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true));
        
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 500));
        
        //Insert tye listb of quote line 
        insert quoteLines;
        
        //List of quote line item child to insert
        /*List<SBQQ__QuoteLine__c> quoteLinesChild = new List<SBQQ__QuoteLine__c>();
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__RequiredBy__c = quoteLines[0].Id , SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 500));
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__RequiredBy__c = quoteLines[0].Id , SBQQ__Product__c = products[1].Id, SBQQ__NetPrice__c = 500));
		
        //insert child quoteLine
        insert quoteLinesChild;*/
        
        //List to hold the SBQQ__QuoteLineGroup__c       
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        
        //Add the new quoteLineGroups list record
        quoteLineGroups.add(new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__BillingFrequency__c = 'Monthly'));
        quoteLineGroups.add(new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__BillingFrequency__c = 'Semiannual'));
        
        //insert the list
        insert quoteLineGroups;
        
        //List of CPQ_ExceptionRequests
        List<CPQ_Exception_Request__c> exceptionRequests = new List<CPQ_Exception_Request__c>();
        
        //Add new ExceptionRequests.
        exceptionRequests.add(new CPQ_Exception_Request__c( Proposal__c = quotes[0].Id, Status__c = 'Draft'));
        exceptionRequests.add(new CPQ_Exception_Request__c( Proposal__c = quotes[1].Id, Status__c = 'Draft'));
        
        //Insert
        insert exceptionRequests;
        
        //Id of CPQ Exception Request.
        Id cpqExceptionRequestsIds = exceptionRequests[0].Id;
        
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
        
        //List of ContentDocumentLink
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        //Insert Content Document Link
        contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = contDoc[0].Id, LinkedEntityId = exceptionRequests[0].Id, ShareType = 'V'));
        contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = contDoc[0].Id, LinkedEntityId = quotes[0].Id, ShareType = 'V'));
        
        insert contentDocumentLinks;
        
        //Map
        Map<Id, SBQQ__Quote__c> mapOfProposals = new Map<Id,SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> mapProposalToBeCloneIdWithClonedProposal = new Map<Id,SBQQ__Quote__c>();
        
        for(SBQQ__Quote__c proposal : quotes){
            if(proposal == quotes[0]){
            	mapOfProposals.put(proposal.Id, proposal);
            }
            else
                mapProposalToBeCloneIdWithClonedProposal.put(quotes[0].Id, proposal);
            
        }
        
        
        //Map
        Map<Id,CPQ_Exception_Request__c> mapOfCPQExceptionRequest = new Map<Id,CPQ_Exception_Request__c>();
        
        for(CPQ_Exception_Request__c exReq : exceptionRequests){
            mapOfCPQExceptionRequest.put(exReq.Proposal__c, exReq);
        }
        
        //Start Testing from here
        Test.startTest();
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(quotes[0]);
        
        //Controller
        ProposalCloneController controller = new ProposalCloneController(sc);
        
        //Call the doCloneProposal method 
        controller.doCloneProposal();
        
        //Call the  cloneFile method
        /*try{
        ProposalCloneController.cloneFile(mapProposalToBeCloneIdWithClonedProposal,mapOfProposals,mapOfCPQExceptionRequest);
        ProposalCloneController.cloneFile(null,null,mapOfCPQExceptionRequest);
        }
        catch(Exception e){

        }*/
        
        //Query on the proposal records
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Status__c, SBQQ__Type__c FROM SBQQ__Quote__c];        
        
        //Assert for the result
        System.assertEquals(4, quoteList.size());
        
        //Query on the Quoteline 
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, SBQQ__Product__c, SBQQ__NetPrice__c FROM SBQQ__QuoteLine__c]; 
        
        //Assert for the result
        System.assertEquals(3, quoteLineList.size());
        
        //Stop Test here
        Test.stopTest();
    }
}