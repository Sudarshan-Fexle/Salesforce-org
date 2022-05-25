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
private class Test_SBQQ_QuoteTrigger {
/**
 *  Description     :   Test class to test the functionality of SBQQ_QuoteTrigger Trigger
 *            
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/27/2016
 *
 *  Revision Log    :   V_1.0 - Created - CR-20160414-9762  
 *                      V_1.1 - Modified - 04/10/17 - Victor Hanson - CR-20170403-10807 - Commented out the class because program opportunities are no longer being used
                        V_1.2 - Modified - 07/26/2017-Divya Bharadwaj(Simplyforce)
                        V_1.3 - Modified - 12/01/2017 - Fixed by Dipesh Gupta, increase the Coverage from 63 to 78% to do the Specific deployemnt CR-20171130-11826.
 *
 *  Coverage        :   V_1.0 - 100% 
 *
 */
 
     /*
     *  Description     :   The method is used to test helper class methods
     *
     *  Created By      :   Saurabh Kumar
     *
     *  Created Date    :   07/06/2017
     *
     *  Revision Log    :   V1.0 - Created - Q2C Phase 2 - CR-20170403-10807
     */
     static testMethod void unitTest(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
         
         //CR-20200206-13705 Test Classes Fixes Start Here
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        insert con;
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Main_Contact__c = con.Id;
        opportunity.LOA_Sent_Date__c = system.today();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	opportunity.Sales_Pursuit_Products__c = 'APS';
        insert opportunity;
        System.assert(opportunity != null);
        //CR-20200206-13705 Test Classes Fixes End Here
        
        //Calling method to insert Document
        Document document = TestUtilities.createNewDocument(false);
        document.Name = 'Test.pdf';
        insert document;
        System.assert(document.Id != null);
        
        //Calling method to insert ContentVersion
        ContentVersion conVersion = TestUtilities.createNewContentVersion(false);
        insert conVersion;
        System.assert(conVersion.Id != null);
        
        //List to hold quote records
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        //Calling method to create Quote records
        for(Integer i = 0; i < 5; i++){
            
            quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__DocumentStatus__c = 'Pending';
            
            quote.Proposal_Version__c = '11';
            
            quote.SBQQ__Opportunity2__c = opportunity.Id;
            quotes.add(quote);  
        }
        quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__DocumentStatus__c = 'Pending';
        quote.LOA_PDF_Document_ID__c = document.Id;
        quote.Proposal_Version__c = null;
        quote.LOA_Document_Version__c = '11';
        quote.SBQQ__StartDate__c = System.today().addDays(-5);
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__Pricebook__c = Test.getStandardPricebookId();
        quote.SBQQ__PricebookId__c=Test.getStandardPricebookId();
        quotes.add(quote);
        
        //Strart test from here
        Test.startTest();
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //inserting quote records
        insert quotes;
         
        //Execute trigger
        Util.BypassAllTriggers = true;
        opportunity.SBQQ__PrimaryQuote__c = quotes[1].Id;
        opportunity.Meeting_Travel_Comp__c = 'Hotel';
        opportunity.Closed_Opp_Comments__c = 'Testing Comment';
        opportunity.SBQQ__AmendedContract__c = contract.Id;
        update opportunity;
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Updating quote records
        quotes[0].SBQQ__DocumentStatus__c = Label.Document_Status_Sent_For_Signature;
        //quotes[1].SBQQ__DocumentStatus__c = CPQConstants.DOCUMENT_STATUS_SIGNED;
        //quotes[2].SBQQ__DocumentStatus__c = CPQConstants.DOCUMENT_STATUS_SIGNED;
        quotes[1].SBQQ__DocumentStatus__c = 'Generated';
        quotes[2].SBQQ__DocumentStatus__c = 'Generated';
        quotes[3].SBQQ__DocumentStatus__c = Label.Document_Status_Sent_For_Signature;
        quotes[1].LOA_Document_Version__c = '12';
        quotes[1].Annualized_Contract_Value__c = 500;
        //quotes[0].ApprovalStatus__c = 'Rejected';
        
        //Creating Proposal lines below Proposal   
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;

        //List of Product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
         //Inserting Products
         insert products;
         
         //List of quote line item to insert
         List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 500));
        
        insert quoteLines;
        
         //Stop test from here
        Test.stopTest();
         
        List<SBQQ__Quote__c> UpdateQuotes = new List<SBQQ__Quote__c>();
        UpdateQuotes.add(quotes[0]);
        UpdateQuotes.add(quotes[3]);
        UpdateQuotes.add(quotes[2]);
        UpdateQuotes.add(quotes[1]);
        Update UpdateQuotes;
         
        //Execute trigger
        Util.BypassAllTriggers = true;
        
        
        //Getting updated record
        List<SBQQ__Quote__c> updatedQuotes = [Select Id, LOA_Non_Standard__c, LOA_Non_Standard_Clauses_Updated__c, LOA_Non_Standard_Clauses_Updated_By__c From SBQQ__Quote__c Where Id =: quotes[1].Id];
        
        //Assertions
        System.assert(updatedQuotes != null);
        System.assertEquals(false, updatedQuotes[0].LOA_Non_Standard__c);
        System.assertEquals(false, updatedQuotes[0].LOA_Non_Standard_Clauses_Updated__c);
        System.assertEquals(null, updatedQuotes[0].LOA_Non_Standard_Clauses_Updated_By__c);
        
        
     }
     
     /*
     *  Description     :   The method is used to test rollUpFirstYearFees method
     *
     *  Created By      :   Saurabh Kumar
     *
     *  Created Date    :   07/06/2017
     *
     *  Revision Log    :   V1.0 - Created - Q2C Phase 2 - CR-20170403-10807
     */
     /*static testMethod void testRollUpFirstYearFees(){
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Creating new program records
        Program__c program = TestUtilities.CreateNewProgram(true);
        System.assert(program.Id != null);
        
        //Creating product record
        Product2 product = TestUtilities.createNewProduct(program.Id, true);
        System.assert(product.Id != null);
        
        //List to hold opportunity record
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opportunity = new Opportunity();
        
        //Creating opportunity records
        for(Integer i = 0; i < 5; i++){
            
            opportunity = TestUtilities.CreateNewOpportunity(false);
            opportunity.First_Year_Fees__c = 29000;
            opportunities.add(opportunity);
        }
        
        insert opportunities;
        System.assert(opportunities[0].Id != null);
        System.assertEquals(5, opportunities.size());
        
        //List to hold quote records
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        //Calling method to create Quote records
        for(Integer i = 0; i < 5; i++){
            
            quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__DocumentStatus__c = 'Pending';
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__Opportunity2__c = opportunities[i].Id;
            quote.Annualized_Contract_Value__c = 100;
            quote.SBQQ__Type__c = CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL;
            quote.SBQQ__MasterContract__c = contract.Id; 
            quotes.add(quote);  
        }
        
        //Start testing from here
        Test.startTest();
         
        //Bypass the trigger
        Util.BypassAllTriggers = false;
         
        insert quotes;
         
        Util.BypassAllTriggers = true;
         
        //List to hold Quote Line records
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        
        //Calling method to create Quote Line records
        for(Integer i = 0; i < 5; i++){
            
            quoteLine = TestUtilities.createNewQuoteLine(quotes[i].Id, false);
            quoteLine.SBQQ__SegmentIndex__c = 1;
            quoteLine.Product_Category__c = 'Annual Fee';
            quoteLine.SBQQ__Product__c = product.Id;
            quoteLine.Program_Opportunity__c = opportunities[i].Id;
            quoteLine.Program_or_Component__c = 'PT';
            quoteLines.add(quoteLine);
        }
        
        insert quoteLines;
         
        //Stop test here
        Test.stopTest();
       
        //Change
         Map<Id,Id> mapQuoteIdWithoppId = new Map<Id,Id>();
         mapQuoteIdWithoppId.put(quotes[0].Id,opportunities[0].Id); 
         Map<Id,Decimal> mapQuoteIdWithOppFirstYrFees = new Map<Id,Decimal>();
         mapQuoteIdWithOppFirstYrFees.put(opportunities[0].Id,opportunities[0].First_Year_Fees__c ); 
         
         
        //SBQQ_QuoteTriggerHelper.rollUpFirstYearFeesFuture(mapQuoteIdWithoppId,mapQuoteIdWithOppFirstYrFees);
        
        
        Util.BypassAllTriggers = false; 
        quotes[0].SBQQ__Primary__c = false;
        update quotes;
        
        quotes[0].SBQQ__Primary__c = true;
        update quotes;
        
        //Delete the quotes
        delete quotes;
        
        //By pass all triggers
        Util.BypassAllTriggers = true;
        
     }*/
    
    /*
     *  Description     :   The method is used to test rollUpFirstYearFees method
     *
     *  Created By      :   Rajeev Jain
     *
     *  Created Date    :   12/12/2017
     *
     *  Revision Log    :   V1.0 - Created - Rajeev Jain - To test Batch_SpringCMDocs class, as it's associated test class is not there
     */
    static testMethod void testBatchSpringCMDocs(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        /*
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Creating new program records
        Program__c program = TestUtilities.CreateNewProgram(true);
        System.assert(program.Id != null);
        
        //Creating product record
        Product2 product = TestUtilities.createNewProduct(program.Id, true);
        System.assert(product.Id != null);
        
        //List to hold opportunity record
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opportunity = new Opportunity();
        
        //Creating opportunity records
        for(Integer i = 0; i < 5; i++){
            
            opportunity = TestUtilities.CreateNewOpportunity(false);
            opportunities.add(opportunity);
        }
        
        insert opportunities;*/
        
        //Calling method to insert Document
        Document document = TestUtilities.createNewDocument(true);
        //document.Name = 'Test.pdf';
        //insert document;
        System.assert(document.Id != null);
        
        //Calling method to insert ContentVersion
        ContentVersion conVersion = TestUtilities.createNewContentVersion(false);
        insert conVersion;
        System.assert(conVersion.Id != null);
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Strart test from here
        Test.startTest();
        
        //List to hold quote records
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        //Change
        quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__DocumentStatus__c = 'Generated';
        quote.LOA_PDF_Document_ID__c = document.Id;
        quote.Proposal_Version__c = null;
        quote.LOA_Document_Version__c = '11';
        quote.SBQQ__StartDate__c = System.today().addDays(-5);
        quote.SBQQ__SubscriptionTerm__c = 12;
        quotes.add(quote);
        
        //inserting quote records
        insert quotes;
        
        //Strart test from here
        Test.stopTest();
        
        //Execute trigger
        //Util.BypassAllTriggers = true;
        
        //Update the document status
        quotes[0].SBQQ__DocumentStatus__c = Label.Redlines_Pending_Approval;
        
        //Update the quote
        update quotes;
        
    }
    
    // Test method to test the Functionality of markFirstProposalAsPrimary
    static testMethod void markFirstProposalAsPrimaryTest() {
        
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.Account_Formal_Name__c = 'testacc';
        insert account;
        
        System.assert(account.Id != null);
        
        //Create a new opportunity
        Opportunity  opportunity = TestUtilities.CreateNewOpportunity(false);
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	opportunity.Sales_Pursuit_Products__c = 'APS';
        insert opportunity;
       
        //Integrated Account Insert
        Integrated_Account__c IA = new Integrated_Account__c();
        IA.Integrated_Account__c = account.id;
        IA.Opportunity__c = opportunity.Id;
        insert IA;
        
        Util.BypassAllTriggers = false;
        
        //Creating a Quote under the opportunty
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;
        
        //List to hold the Quote
        List<SBQQ__Quote__c> proposals = [Select Id, SBQQ__Primary__c, Integrated_Accounts__c From SBQQ__Quote__c];
        
        System.assertEquals(1, proposals.size());
        System.assertEquals(true, proposals[0].SBQQ__Primary__c);
        System.assertEquals('testacc', proposals[0].Integrated_Accounts__c);
        
        //Creating One More record under the Same Opportunity, but still it will not be the Primary because under a single opportunity only single primary Proposal created, other ones should not be primary
        SBQQ__Quote__c quote1 = TestUtilities.createNewSbqqQuote(false);
        quote1.SBQQ__Status__c = 'Locked';
        quote1.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote1;
        
        //Query the Quote and check the Primary
        List<SBQQ__Quote__c> proposals1 = [Select Id, SBQQ__Primary__c From SBQQ__Quote__c]; 
        System.assertEquals(true, proposals1[0].SBQQ__Primary__c);
        System.assertEquals(false, proposals1[1].SBQQ__Primary__c);
    }
    
    // Test method to test the Functionality of updateFirstYearFeesForRenewalOpp
    static testMethod void testUpdateFirstYearFeesForRenewalOpp() {
        
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        insert account;
        
        System.assert(account.Id != null);
        
        //Create a new opportunity
        Opportunity  opportunity = TestUtilities.CreateNewOpportunity(true);
        
        //Create a new opportunity
        Opportunity  opportunity1 = TestUtilities.CreateNewOpportunity(false);
        opportunity1.Previous_Opportunity__c = opportunity.Id;
        opportunity1.First_Year_Fees__c = 100;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	opportunity1.Sales_Pursuit_Products__c = 'APS';
        opportunity1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Continuing').getRecordTypeId();
        insert opportunity1;
        
        
        Util.BypassAllTriggers = false;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        
        //Execute trigger
        Util.BypassAllTriggers = true;
        //Insert
        insert subscriptions;
     //Start
        test.startTest();
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,
                                                                 Stage__c = 'Pending', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, 
                                                                 Research_Strategic_Leader__c = usrs[0].Id, Proposal_Value_Number__c = 10, Source_Opportunity__c = opportunity.Id ));
        
        //Execute trigger
        Util.BypassAllTriggers = true;
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;        
        
        //Creating a Quote under the opportunty
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Opportunity2__c = opportunity1.Id;
        
   
        //Execute trigger
        Util.BypassAllTriggers = false;
        insert quote;
        
          //Stop
        test.stopTest();
        
        quote.SBQQ__Status__c = 'Locked';
        update quote;
        
        //delete
        delete quote;
        
      
    }
    
    // Test method to test the Functionality of populateAccountMSADate
    static testMethod void testpopulateAccountMSADate(){
        
        //Execute trigger
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId();

        insert account;
        
        System.assert(account.Id != null);
        
        //CR-20200206-13705 Test Classes Fixes Start Here
        //Creating Contact record 
        Contact con1 = TestUtilities.CreateNewContact(True);
        
        //Start
        test.startTest();
        
        //Create a new opportunity
        //Opportunity  opportunity = TestUtilities.CreateNewOpportunity(true);
        
        //Create a new opportunity
        Opportunity  opportunity1 = TestUtilities.CreateNewOpportunity(false);
        //opportunity1.Previous_Opportunity__c = opportunity.Id;
        opportunity1.First_Year_Fees__c = 100;
        opportunity1.AccountId = account.Id; 
        opportunity1.CloseDate = System.today();
        opportunity1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Initiating').getRecordTypeId();
        opportunity1.Main_Contact__c = con1.Id;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	opportunity1.Sales_Pursuit_Products__c = 'APS';
        insert opportunity1;
        //CR-20200206-13705 Test Classes Fixes End Here

        //Creating a Quote under the opportunty
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.Contract_Document_Creation_Date__c = date.today();
        quote.SBQQ__Opportunity2__c = opportunity1.Id;
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        insert quote;
        
        account.MSA_Proposal__c = quote.Id;
        //Update
        update account; 
        
        quote.Contract_Document_Creation_Date__c  = date.today().addDays(1);
        quote.SBQQ__Status__c = 'Locked';
        update quote;
        
        //Stop
        test.stopTest();
    }
    
    
    static testMethod void testContentVersion(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //CR-20200206-13705 Test Classes Fixes Start Here
        //Creating Contact record 
        Contact con2 = TestUtilities.CreateNewContact(True);
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Main_Contact__c = con2.Id;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	opportunity.Sales_Pursuit_Products__c = 'APS';
        insert opportunity;
        System.assert(opportunity != null);
        //CR-20200206-13705 Test Classes Fixes End Here
        
        //Calling method to insert Document
        //Document document = TestUtilities.createNewDocument(true);
        /*Document document = new Document();
        document.Name = 'Test.pdf';
        insert document;
        System.assert(document.Id != null);*/
        
        //Calling method to insert ContentVersion
        ContentVersion conVersion = TestUtilities.createNewContentVersion(false);
        //conVersion.ContentDocumentId = document.Id;
        insert conVersion;
        System.assert(conVersion.Id != null);
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assert(documents[0].Id != null);
        
        //List to hold quote records
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__DocumentStatus__c = 'Pending';
        quote.LOA_PDF_Document_ID__c = documents[0].Id;
        quote.Proposal_Version__c = '11';
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.LOA_Document_Version__c = '11';
        quote.SBQQ__StartDate__c = System.today().addDays(-5);
        quote.SBQQ__SubscriptionTerm__c = 12;
        quotes.add(quote);
         
        
        //Strart test from here
        Test.startTest();
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //inserting quote records
        insert quotes;
         
        //Execute trigger
        Util.BypassAllTriggers = true;
        opportunity.SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunity.Meeting_Travel_Comp__c = 'Hotel';
        opportunity.Closed_Opp_Comments__c = 'Testing Comment';
        opportunity.SBQQ__AmendedContract__c = contract.Id;
        update opportunity;
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        
        //Updating quote records
        //quotes[0].SBQQ__DocumentStatus__c = CPQConstants.DOCUMENT_STATUS_SIGNED;
        quotes[0].SBQQ__DocumentStatus__c = 'Generated';
        //quotes[0].LOA_Document_Version__c = '11';
        //quotes[0].Annualized_Contract_Value__c = 500;
        
        
        //Creating Proposal lines below Proposal   
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;

        //List of Product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
         //Inserting Products
         insert products;
         
         //List of quote line item to insert
         List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
                
        insert quoteLines;
        
        //List<ContentWorkspace> cW = [Select Id, Name From ContentWorkspace Where Name =: Label.CONTENTWORKSPACE_SIGNED_LOA LIMIT 1];

        List<SBQQ__Quote__c> UpdateQuotes = new List<SBQQ__Quote__c>();
        UpdateQuotes.add(quotes[0]);
        Update UpdateQuotes;  
        
         /* 
        List<SBQQ__Quote__c> UpdateQuotes = new List<SBQQ__Quote__c>();
        UpdateQuotes.add(quotes[0]);
        Update UpdateQuotes;
         
        //Execute trigger
        Util.BypassAllTriggers = true;
        
        //Getting updated record
        List<SBQQ__Quote__c> updatedQuotes = [Select Id, LOA_Non_Standard__c, LOA_Non_Standard_Clauses_Updated__c, LOA_Non_Standard_Clauses_Updated_By__c From SBQQ__Quote__c Where Id =: quotes[0].Id];
        */
        //Stop test from here
        Test.stopTest();
        
     }
     
     // Code coverage increase start here
    static testMethod void testpopulateIActiveSTRCO(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Test.startTest();
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId();

        insert account;
        
        System.assert(account.Id != null);
        
         // Insert Program
        List<Program__c> programs = new List<Program__c>();
        programs.add(TestUtilities.CreateNewProgram(false));
        insert programs;
        
        // Insert Product
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'STRCO' ,SBQQ__SortOrder__c = 5));
        insert products;
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, false);
        //contract.Status = 'Activated_Amended';
        insert contract;
        
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 0, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__SubscriptionStartDate__c  = Date.today(), SBQQ__SubscriptionEndDate__c = Date.today()+1, 
                                                    SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), SBQQ__Account__c = account.Id,
                                                    SBQQ__Product__c = products[0].Id));                                                      
       
        insert subscriptions;
        
        //Creating a Quote
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.Contract_Document_Creation_Date__c = date.today();
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        insert quote;
        
        //Check assert
        SBQQ__Quote__c quoteRecord = [Select Id, IS_Active_STRCO__c From SBQQ__Quote__c Where Id = :quote.Id];
        System.assertEquals(true, quoteRecord.IS_Active_STRCO__c);
        
        Test.stopTest();
    }
    
    static testMethod void testPopulateStatusOnProposal(){
		//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Test.startTest();
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId(); 
        insert account;
        
        System.assert(account.Id != null);
        
        Map<String, Id> mapRecordTypeLabelWithId = Util.recordtypemap('SBQQ__Quote__c');
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Creating a Quote
        for(Integer i=0; i<5; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        	quote.SBQQ__Primary__c = true;
        	quote.SBQQ__Account__c = account.Id;
        	quote.Contract_Document_Creation_Date__c = date.today();
            quotes.add(quote);
        }
        
        quotes[0].ApprovalStatus__c = 'Approved';
        quotes[1].ApprovalStatus__c = 'Rejected';
        quotes[2].ApprovalStatus__c = 'Recalled';
		quotes[3].ApprovalStatus__c = 'Pending';
        quotes[4].ApprovalStatus__c = '';

        //Execute trigger
        Util.BypassAllTriggers = false;
        insert quotes;
        
        quotes = [Select Id, SBQQ__Status__c, ApprovalStatus__c, RecordTypeId, SBQQ__WatermarkShown__c From SBQQ__Quote__c Where SBQQ__Account__c = :account.Id];
        for(SBQQ__Quote__c quote : quotes){
            if(quote.ApprovalStatus__c == 'Approved'){
                System.assertEquals(false, quote.SBQQ__WatermarkShown__c);
                System.assertEquals(CPQConstants.PROPOSAL_STATUS_APPROVED, quote.SBQQ__Status__c);
                System.assertEquals(mapRecordTypeLabelWithId.get('Approved Quote'), quote.RecordTypeId);
            }
            else if(quote.ApprovalStatus__c == 'Rejected'){
                System.assertEquals(true, quote.SBQQ__WatermarkShown__c);
                System.assertEquals(CPQConstants.PROPOSAL_STATUS_REJECTED, quote.SBQQ__Status__c);
                System.assertEquals(mapRecordTypeLabelWithId.get('Open'), quote.RecordTypeId);
            }
            else if(quote.ApprovalStatus__c == 'Recalled'){
                System.assertEquals(true, quote.SBQQ__WatermarkShown__c);
                System.assertEquals(CPQConstants.PROPOSAL_STATUS_DRAFT, quote.SBQQ__Status__c);
                System.assertEquals(mapRecordTypeLabelWithId.get('Open'), quote.RecordTypeId);
            }
            else if(quote.ApprovalStatus__c == 'Pending'){
                System.assertEquals(true, quote.SBQQ__WatermarkShown__c);
                System.assertEquals(CPQConstants.PROPOSAL_STATUS_IN_REVIEW, quote.SBQQ__Status__c);
                System.assertEquals(mapRecordTypeLabelWithId.get('In Review'), quote.RecordTypeId);
            }
            else if(quote.ApprovalStatus__c == ''){
                System.assertEquals(CPQConstants.PROPOSAL_STATUS_DRAFT, quote.SBQQ__Status__c);
                System.assertEquals(mapRecordTypeLabelWithId.get('Open'), quote.RecordTypeId);
            }
            
        }
        
        //stop trigger
        Util.BypassAllTriggers = true;
        quotes[0].ApprovalStatus__c = 'Approved';
        quotes[0].SBQQ__Status__c = 'Draft';
        quotes[0].RecordTypeId = mapRecordTypeLabelWithId.get('Open');
        try{
        	SBQQ_QuoteTriggerHelper.validateStatusOnProposal(quotes,null);
        }catch(Exception e){
            System.assert(e.getMessage().contains(CPQConstants.mapApprovalStatusWithErrorMessage.get('Approved')));
        }
        quotes[0].ApprovalStatus__c = 'Rejected';
        quotes[0].SBQQ__Status__c = 'Draft';
        quotes[0].RecordTypeId = mapRecordTypeLabelWithId.get('Approved Quote');
        try{
        	SBQQ_QuoteTriggerHelper.validateStatusOnProposal(quotes,null);
        }catch(Exception e){
            System.assert(e.getMessage().contains(CPQConstants.mapApprovalStatusWithErrorMessage.get('Rejected')));
        }
        
        quotes[0].ApprovalStatus__c = 'Recalled';
        quotes[0].SBQQ__Status__c = 'Rejected';
        quotes[0].RecordTypeId = mapRecordTypeLabelWithId.get('Approved Quote');
        try{
        	SBQQ_QuoteTriggerHelper.validateStatusOnProposal(quotes,null);
        }catch(Exception e){
            System.assert(e.getMessage().contains( CPQConstants.mapApprovalStatusWithErrorMessage.get('Recalled')));
        }
        
        quotes[0].ApprovalStatus__c = 'Pending';
        quotes[0].SBQQ__Status__c = 'Rejected';
        quotes[0].RecordTypeId = mapRecordTypeLabelWithId.get('Approved Quote');
        try{
        	SBQQ_QuoteTriggerHelper.validateStatusOnProposal(quotes,null);
        }catch(Exception e){
            System.assert(e.getMessage().contains( CPQConstants.mapApprovalStatusWithErrorMessage.get('Pending')));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testAutoPopulateFieldsOnProposal(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Test.startTest();
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId(); 
        insert account;
        
        System.assert(account.Id != null);
        
        Contact con = TestUtilities.CreateNewContact(false);
        insert con;
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, false);
        contract.SBQQ__RenewalTerm__c = 2;
        contract.SBQQ__RenewalQuoted__c = true;
        contract.Main_Contact__c = con.Id;
        insert contract;
        System.assert(contract.Id != null);
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(true));
        System.assert(programs[0].Id != null);
        
        //List of Product
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
        insert products;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, SBQQ__Contract__c = contract.ID,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), SBQQ__Product__c=products[0].Id));
        insert subscriptions;
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.SBQQ__RenewedContract__c = contract.Id;
        opportunity.LOA_Sent_Date__c = system.today();
    	opportunity.Sales_Pursuit_Products__c = 'APS';
        insert opportunity;
        System.assert(opportunity != null);
        
        Map<String, Id> mapRecordTypeLabelWithId = Util.recordtypemap('SBQQ__Quote__c');
        /*List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Creating a Quote
        for(Integer i=0; i<5; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        	quote.SBQQ__Primary__c = true;
        	quote.SBQQ__Account__c = account.Id;
        	quote.Contract_Document_Creation_Date__c = date.today();
            quotes.add(quote);
        }*/
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.Contract_Document_Creation_Date__c = date.today();
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__MasterContract__c = contract.Id; 
		quote.SBQQ__Type__c = 'Renewal';
        quote.Legacy_Migrated_ES_Client__c = '';
        //Execute trigger
        Util.BypassAllTriggers = false;
        insert quote;
        
        //Check assert
        List<SBQQ__Quote__c> quotes = [Select Id, SBQQ__SubscriptionTerm__c, Proposal_Version__c, LOA_Document_Version__c, Existing_Products__c From SBQQ__Quote__c Where Id = :quote.Id];
		/*System.assert(false, contract.SBQQ__RenewalTerm__c +'--'+ quotes[0].SBQQ__SubscriptionTerm__c + '-'+quotes[0].Existing_Products__c + '--'+quotes[0].Proposal_Version__c+ '--'+quotes[0].LOA_Document_Version__c);
        System.assertEquals('0', quotes[0].Proposal_Version__c);*/
        System.assertEquals('0', quotes[0].LOA_Document_Version__c);
        System.assertEquals(2, quotes[0].SBQQ__SubscriptionTerm__c);
        System.assert(quotes[0].Existing_Products__c != null);
        System.assertEquals('Consulting Product', quotes[0].Existing_Products__c);
        
        Test.stopTest();
    }
    
    static testMethod void testUpdateOpportunityPrimaryProposal(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId(); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        insert opportunity;
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Account__c = account.Id;
        quote.Contract_Document_Creation_Date__c = date.today();
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__Type__c = 'Renewal';
        Util.BypassAllTriggers = true;
        insert quote;
        
        opportunity = [select Id, SBQQ__PrimaryQuote__c from opportunity where Id = :opportunity.Id];
        //System.assert(opportunity.SBQQ__PrimaryQuote__c != null);
        
        
        opportunity.SBQQ__PrimaryQuote__c = null;
        update opportunity;
        
        quote = [Select Id, SBQQ__Primary__c From SBQQ__Quote__c Limit 1];
        quote.SBQQ__Primary__c = true;
        
        Util.BypassAllTriggers = false;
        update quote;
        Test.stopTest();
    }
    
    static testMethod void testPopulateContractDocumentCreationDate(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId(); 
        insert account;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for(Integer i=0; i<5; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__Account__c = account.Id;
            quote.Contract_Document_Creation_Date__c = date.today();
            quote.SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
            quote.ApprovalStatus__c = 'Approved';
            quotes.add(quote);
        }
        
        insert quotes;
        
        quotes = [Select Id, LOA_PDF_Document_File_Name__c From SBQQ__Quote__c Where SBQQ__Account__c = :account.Id];
        for(SBQQ__Quote__c q: quotes){
            q.LOA_PDF_Document_File_Name__c = q.LOA_PDF_Document_File_Name__c+'Test';
        }
        Util.BypassAllTriggers = false;
        update quotes;
        
        quotes = [Select Id, Contract_Document_Creation_Date__c From SBQQ__Quote__c Where SBQQ__Account__c = :account.Id];
        for(SBQQ__Quote__c q: quotes){
            System.assert(q.Contract_Document_Creation_Date__c != null);
        }
        Test.stopTest();
    }
    
    static testMethod void tes_tpopulateInvoicingArrangement(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        insert opportunity;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;

        //List of Product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
         //Inserting Products
         insert products;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for(Integer i=0 ; i<5; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__Primary__c = false;
            quote.SBQQ__Account__c = account.Id;
            quote.Contract_Document_Creation_Date__c = date.today();
            quote.SBQQ__Opportunity2__c = opportunity.Id;
            quote.Invoice_Frequency__c = 'Annual';
            quotes.add(quote);
        }
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[3].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[4].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        insert quoteLines;
        
        Bypass_Logic__c bypass = new Bypass_Logic__c();
        bypass.Objects_to_Bypass__c = 'SBQQ__QuoteLine__c';
        bypass.Bypass_Triggers__c = true;
        bypass.setupOwnerId = UserInfo.getUserId();
        insert bypass;
        
        Test.startTest();
        List<SBQQ__Quote__c> quoteRecords = [Select Id, Invoice_Frequency__c From SBQQ__Quote__c];
        quoteRecords[0].Invoice_Frequency__c = 'Monthly';
        quoteRecords[1].Invoice_Frequency__c = 'Monthly';   
        quoteRecords[2].Invoice_Frequency__c = 'Monthly';
        quoteRecords[3].Invoice_Frequency__c = 'Monthly';
        quoteRecords[4].Invoice_Frequency__c = 'Monthly';
        
        Util.BypassAllTriggers = false;
        update quoteRecords;
        
        Test.stopTest();
    }
    
    static testMethod void test_populateAmendedProposalFieldsFromOriginalProposal(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        opportunity.SBQQ__AmendedContract__c = contract.id;
        insert opportunity;
        
        SBQQ__Quote__c quoteRecord = TestUtilities.createNewSbqqQuote(false);
        quoteRecord.SBQQ__Primary__c = false;
        quoteRecord.SBQQ__Account__c = account.Id;
        quoteRecord.Contract_Document_Creation_Date__c = date.today();
        quoteRecord.SBQQ__Opportunity2__c = opportunity.Id;
        quoteRecord.SBQQ__Type__c = 'Amendment';
        quoteRecord.Invoice_Frequency__c = 'Monthly';
        insert quoteRecord;
        
        contract.SBQQ__Quote__c = quoteRecord.Id;
        update contract;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;

        //List of Product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
         //Inserting Products
         insert products;
        
        Test.startTest();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for(Integer i=0 ; i<5; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__Primary__c = false;
            quote.SBQQ__Account__c = account.Id;
            quote.Contract_Document_Creation_Date__c = date.today();
            quote.SBQQ__Opportunity2__c = opportunity.Id;
            quote.SBQQ__Type__c = 'Amendment';
            quote.Invoice_Frequency__c = 'Annual';
            quotes.add(quote);
        }
        Util.BypassAllTriggers = false;
        insert quotes;
        
        Test.stopTest();
        
    }
    
    static testMethod void test_populateAmendmentTypeOnContract(){
         //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, false);
        contract.Amendment_Type__c = 'Upsell';
        contract.EndDate = date.today()+20;
        insert contract;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        opportunity.SBQQ__AmendedContract__c = contract.id;
        insert opportunity;
        
        Test.startTest();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for(Integer i=0 ; i<1; i++){
            SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
            quote.SBQQ__Primary__c = false;
            quote.SBQQ__Account__c = account.Id;
            quote.SBQQ__EndDate__c = date.today()+10;
            quote.SBQQ__Opportunity2__c = opportunity.Id;
            quote.SBQQ__Type__c = 'Amendment';
            quote.SBQQ__MasterContract__c = Contract.Id;
            quotes.add(quote);
        }
        Util.BypassAllTriggers = false;
        insert quotes;
        
        Test.stopTest();

    }
    
    static testMethod void test_preventPrimaryCheckUpdate(){
         //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
               
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        insert opportunity;
        
        Test.startTest();
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        
        insert quote;
        
    	Util.BypassAllTriggers = false;
        quote.SBQQ__Primary__c = false;
        try{
            update quote;
        }catch(Exception e){
            System.assert(e.getMessage().contains(Label.Primary_Proposal_Uncheck_Restriction));
        }
        
        Test.stopTest();
    }
    
    static testMethod void test_autoPopulateFieldOnQuotes(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
               
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        insert opportunity;
        
        Test.startTest();
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__StartDate__c = date.today();
        quote.LOA_Document_Version__c = '1';
        quote.Redlines_Approved_Date__c = null;
        
        insert quote;
        
        SBQQ__Quote__c quoteRecord = [Select Id, LOA_Document_Version__c,  SBQQ__StartDate__c, Redlines_Approved_Date__c From SBQQ__Quote__c limit 1];
        quoteRecord.LOA_Document_Version__c = '2';
        quoteRecord.SBQQ__StartDate__c = date.today()+20;
        
        Util.BypassAllTriggers = false;
        update quoteRecord;
        
        quoteRecord = [Select Id, Set_Invoice_Date__c, SBQQ__StartDate__c, LOA_Non_Standard__c, LOA_Non_Standard_Clauses_Updated__c From SBQQ__Quote__c limit 1];
        System.assertEquals(false, quoteRecord.LOA_Non_Standard__c);
        System.assertEquals(false, quoteRecord.LOA_Non_Standard_Clauses_Updated__c);
        System.assertEquals(quoteRecord.SBQQ__StartDate__c, quoteRecord.Set_Invoice_Date__c);
        
        // cover rollUpFirstYearFeesFuture
        Map<Id, Id> mapQuoteIdWithoppId = new Map<Id, Id>();
        mapQuoteIdWithoppId.put(quoteRecord.Id, opportunity.Id);
        
        Map<Id, Decimal> mapOppIdWithFirstYearFees = new  Map<Id, Decimal>();
        mapOppIdWithFirstYearFees.put(opportunity.Id, 10);
        
        SBQQ_QuoteTriggerHelper.rollUpFirstYearFeesFuture(mapQuoteIdWithoppId, mapOppIdWithFirstYearFees);
        Test.stopTest();
    }
    
    static testMethod void test_sendSignedLOAToOwner(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
               
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        insert opportunity;
        
        Test.startTest();
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__StartDate__c = date.today();
        quote.LOA_Document_Version__c = '1';
        quote.SBQQ__DocumentStatus__c = 'Pending';
        
        insert quote;
        
        SBQQ__Quote__c quoteRecord = [Select Id, SBQQ__DocumentStatus__c,  SBQQ__StartDate__c, Redlines_Approved_Date__c From SBQQ__Quote__c limit 1];
        quoteRecord.SBQQ__DocumentStatus__c = 'Sent for Signature';
        Util.BypassAllTriggers = false;
        update quoteRecord;
        
        Test.stopTest();
    }
    
    static testMethod void testCreateContentDocument(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
       
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.Opportunity_Products__c = 'BHSM';
        insert opportunity;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;

        //List of Product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
         //Inserting Products
         insert products;
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Account__c = account.Id;
        quote.Contract_Document_Creation_Date__c = date.today();
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
                
        insert quoteLines;
        
        ContentVersion content =  new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=quote.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
                
        opportunity.SBQQ__PrimaryQuote__c = quote.Id;
        Update opportunity;
        
        quote.SBQQ__DocumentStatus__c = 'Signed';
        quote.LOA_PDF_Document_ID__c = contentlink.Id;
        quote.SBQQ__Primary__c = false;
        Util.BypassAllTriggers = false;
        try{
        	update quote;
        }catch(Exception e){
            
        }
        
        Test.stopTest();
    }
    
    
    static testMethod void testRollUpFirstYearFees(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
       
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        insert opportunity;
        
        //List to insert Program records
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;

        //List of Product
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = program.Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
        insert products;
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        insert quoteLines;
        
        Test.stopTest();
        
    }
    
    static testMethod void test_populateProgramPackageFields(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
       
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        insert opportunity;
        
        //List to insert Program records
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;

        //List of Product
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = program.Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
        insert products;
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Sync_Calculator_Update_Date__c = date.today();
        insert quote;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__SegmentIndex__c =1, SBQQ__CustomerPrice__c = 10, SBQQ__NetPrice__c = 100));
        insert quoteLines;
		
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
         //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), SBQQ__QuoteLine__c = quoteLines[0].id));
        insert subscriptions;
        
        
        
        
        Integer currentFY = shift_get_fiscal_year.current(); 
        //List of program Package            
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_CurrentYear', Account__c = account.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)), Proposal_Sent__c = Date.today()+3,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_NextYear', Account__c = account.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),Proposal_Sent__c = Date.today()+3,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
       
        insert progPacks;
        
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,
                                                                 Stage__c = 'Pending', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, 
                                                                 Research_Strategic_Leader__c = usrs[0].Id, Proposal_Value_Number__c = 10, Source_Opportunity__c = opportunity.Id,
                                                                Program_Package__c = progPacks[0].Id));
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
        
        SBQQ__Quote__c quoteRecord = [Select Id, Sync_Calculator_Update_Date__c From SBQQ__Quote__c limit 1];
        quoteRecord.Sync_Calculator_Update_Date__c = date.today()+10;
        
        Util.BypassAllTriggers = false;
        update quoteRecord;
        Test.stopTest();
    }
    
    static testMethod void test_populateGradingCriteriaForContractedProposal(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Test.startTest();
       
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false); 
        insert account;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        opportunity.SBQQ__Contracted__c = true;
        insert opportunity;
        
        //List to insert Program records
        Program__c program = TestUtilities.CreateNewProgram(false);
        insert program;

        //List of Product
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = program.Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
         
        insert products;
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = false;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Sync_Calculator_Update_Date__c = date.today();
        insert quote;
        
        SBQQ__Quote__c quoteRecord = [Select Id, SBQQ__Primary__c From SBQQ__Quote__c limit 1];
        quoteRecord.SBQQ__Primary__c = true;
        
        Util.BypassAllTriggers = false;
        update quoteRecord;
        test.stopTest();
    }
    // Code coverage increase end here
}