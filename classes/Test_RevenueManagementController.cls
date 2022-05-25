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
public class Test_RevenueManagementController {
    
    /**
    *   Description     :   Testing for RevenueManagementController class
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   02/20/2017
    *
    *   Revision Log    :   V1.0 - Created - CR-20161102-10316
    *                       V1.1 - Modified - Abhinav Sharma - 5/15/2017 - CR-20170508-10923
    *                       V1.2 - Modified - Abhinav Sharma - 5/16/2017 - CR-20170508-10914
    *                       V1.3 - Modified - Abhinav Sharma - 05/18/2017 - CR-20170508-10905
    *                       V_1.4 - Modified By - Subhash Garhwal - 8/25/2017 - Issue--CR10808--QA--00005222 - Removed SBQQ__Product__r.Program_Family__c field
    *			    V_1.5 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    *   Code Coverage   :   100%
    **/ 
  
  /**
    *   Description     :   This method is used to insert common data
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    @testSetup static void setupData(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        //Creating of Account records
        accounts.add(new Account(Name = 'Ascension Health - St. Louis - MO', Status__c = 'Active'));
        accounts.add(new Account(Name = 'RWJBarnabas Health - West Orange - NJ', Status__c = 'Active'));
        insert accounts;
        
        //Query on Opportunity record types
        List<RecordType> recordTypesOfOpp = [Select Id, DeveloperName From RecordType Where sObjectType = 'Opportunity' AND DeveloperName = 'BI_Contract_Maintenance'];
        
        //List to hold Opportunity Records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity records
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp1', StageName = 'Phone Appointment Scheduled', CloseDate = System.today().addDays(30)));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp2', StageName = 'Proposal In Progress', CloseDate = System.today().addDays(30)));
        insert opportunities;
        
        //List to hold Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Creating Program records
        programs.add(new Program__c(Name = 'American HealthLine', Program_Acronym__c = 'AHCP',  Create_memberships__c = 'No', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Physician Boot Camp on Leadership Fundamentals', Program_Acronym__c = 'ACBP',   Create_memberships__c = 'No', Status__c = 'Active'));
        insert programs;
        
        //Query on Contact record types
        List<RecordType> recordTypesOfCon = [Select Id, DeveloperName From RecordType Where sObjectType = 'Contact' AND DeveloperName = 'External'];
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Creating Contact Records
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test1', AccountId = accounts[0].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test2', AccountId = accounts[0].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test3', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test4', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        insert contacts;
        
        //List to hold Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Creating Contract ABC Records
        contracts.add(new Contract__c(Name = 'Test ContractABC1', Payer_Account__c = accounts[0].Id, Source_Opportunity__c = opportunities[0].Id, 
                                      Program__c = programs[0].Id,  Invoicing_Arrangement__c = 'Annual', Main_Contact__c = contacts[0].Id,
                                      Invoice_Contact__c = contacts[1].Id, Year__c = '2016', Type__c = 'NBB', Start__c = System.today(),
                                      End__c = System.today().addDays(+10), Status__c = 'Pending', Term_Type__c = 'Opt Out', Years_in_Term__c = 2,
                                      Contract_Count__c = 2, Contract_Currency__c = 'EUR - Euro', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        contracts.add(new Contract__c(Name = 'Test ContractABC2', Payer_Account__c = accounts[1].Id, Source_Opportunity__c = opportunities[1].Id, 
                                      Program__c = programs[1].Id,  Invoicing_Arrangement__c = 'Semi-Annual', Main_Contact__c = contacts[2].Id,
                                      Invoice_Contact__c = contacts[3].Id, Year__c = '2017', Type__c = 'Renewal', Start__c = System.today().addDays(-5),
                                      End__c = System.today().addDays(1), Status__c = 'Void', Term_Type__c = 'Fixed Term', Years_in_Term__c = 3,
                                      Contract_Count__c = 3, Contract_Currency__c = 'QAR - Qatar Rial', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        insert contracts;
        
        //List to hold Setting records
        List<ffrr__Settings__c> primaryLevelSettings = new List<ffrr__Settings__c>();
        
        //Creating Setting record
        primaryLevelSettings.add(new ffrr__Settings__c(Name = 'Contract ABC', ffrr__SettingsLevel__c = 'Primary', ffrr__Object__c = 'Contract__c',
                                                 ffrr__SettingsType__c = 'Actual', ffrr__TransactionLineRelationship__c = 'Contract_ABC__c',
                                                 ffrr__Description__c = 'Name', ffrr__StartDate__c = 'Start__c',
                                                 ffrr__EndDate__c = 'End__c', ffrr__TotalRevenue__c = 'Negotiated_Amount__c', ffrr__ActiveField__c = 'Active__c',
                                                 ffrr__ActiveValue__c = 'True', ffrr__IncludeActiveValue__c = 'Include', ffrr__Currency__c = 'CurrencyIsoCode', 
                                                 ffrr__CompletedField__c = 'Active__c',
                                                 ffrr__CompletedValue__c = 'True', ffrr__IncludeCompletedValue__c = 'Include', ffrr__IncomeStatementAccount__c = 'x',
                                                 ffrr__BalanceSheetAccount__c = 'x', ffrr__FixedIncomeStatementAccountCode__c = true, ffrr__FixedBalanceSheetAccountCode__c = true));
        insert primaryLevelSettings;
        
        //List to hold Setting records
        List<ffrr__Settings__c> secondLevelSettings = new List<ffrr__Settings__c>();
        
        //Creating Setting records
        secondLevelSettings.add(new ffrr__Settings__c(Name = 'Revenue ABC', ffrr__SettingsLevel__c = 'Level 2', ffrr__Object__c = 'ABC_Revenue__c',
                                                    ffrr__ParentSettings__c = primaryLevelSettings[0].Id, ffrr__PrimaryRelationship__c = 'Contract_ABC__c', 
                                                    ffrr__SettingsType__c = 'Actual', ffrr__TransactionLineRelationship__c = 'ABC_Revenue__c', 
                                                    ffrr__AccountName__c = 'Institution__c',
                                                    ffrr__Description__c = 'Name', ffrr__StartDate__c = 'Recognition_Start_Date__c', ffrr__EndDate__c = 'Recognition_End_Date__c',
                                                    ffrr__TotalRevenue__c = 'GAAP_Amount__c', ffrr__ActiveField__c = 'Rev_Rec_Complete__c',ffrr__ActiveValue__c = 'True',
                                                    ffrr__IncludeActiveValue__c = 'Include', ffrr__Currency__c = 'CurrencyIsoCode',
                                                    ffrr__CompletedField__c = 'Rev_Rec_Complete__c', ffrr__CompletedValue__c = 'True', ffrr__IncludeCompletedValue__c = 'Exclude',
                                                    ffrr__RevenueRecognitionCompleted__c = 'Rev_Rec_Complete__c', 
                                                    ffrr__IncomeStatementAccount__c = 'x', ffrr__BalanceSheetAccount__c = 'x',
                                                    ffrr__FixedIncomeStatementAccountCode__c = true, ffrr__FixedBalanceSheetAccountCode__c = true));
        insert secondLevelSettings;
        
        //List to hold setting records
        List<ffrr__Settings__c> thirdLevelSettings = new List<ffrr__Settings__c>();
        
        //Creating Setting records
        thirdLevelSettings.add(new ffrr__Settings__c(Name = 'Revenue ABC Line - Contract', ffrr__SettingsLevel__c = 'Level 3', ffrr__Object__c = 'ABC_Revenue_Line__c',
                                                  ffrr__ParentSettings__c = secondLevelSettings[0].Id, ffrr__PrimaryRelationship__c = 'ABC_Revenue__c', ffrr__SettingsType__c = 'Actual',
                                                  ffrr__TransactionLineRelationship__c = 'ABC_Revenue_Line__c', ffrr__Description__c = 'Name',
                                                  ffrr__StartDate__c = 'Recognition_Start_Date__c', ffrr__EndDate__c = 'Recognition_End_Date__c',
                                                  ffrr__TotalRevenue__c = 'Negotiated_Amount__c', ffrr__ActiveField__c = 'Rev_Rec_Complete__c',ffrr__ActiveValue__c = 'True',
                                                  ffrr__IncludeActiveValue__c = 'Include', ffrr__Currency__c = 'CurrencyIsoCode',
                                                  ffrr__CompletedField__c = 'Rev_Rec_Complete__c', ffrr__CompletedValue__c = 'True', ffrr__IncludeCompletedValue__c = 'Exclude',
                                                  ffrr__RecognizedToDateValue__c = 'Recognized_to_Date_Contract__c', ffrr__RevenueRecognitionCompleted__c = 'Rev_Rec_Complete__c',
                                                  ffrr__IncomeStatementAccount__c = 'x', ffrr__BalanceSheetAccount__c = 'x',
                                                  ffrr__FixedIncomeStatementAccountCode__c = true, ffrr__FixedBalanceSheetAccountCode__c = true));
        thirdLevelSettings.add(new ffrr__Settings__c(Name = 'Revenue ABC Line - GAAP', ffrr__SettingsLevel__c = 'Level 3', ffrr__Object__c = 'ABC_Revenue_Line__c',
                                                  ffrr__ParentSettings__c = secondLevelSettings[0].Id, ffrr__PrimaryRelationship__c = 'ABC_Revenue__c', ffrr__SettingsType__c = 'Actual',
                                                  ffrr__TransactionLineRelationship__c = 'ABC_Revenue_Line__c', ffrr__Description__c = 'Name',
                                                  ffrr__StartDate__c = 'Recognition_Start_Date__c', ffrr__EndDate__c = 'Recognition_End_Date__c',
                                                  ffrr__TotalRevenue__c = 'GAAP_Amount__c', ffrr__ActiveField__c = 'Rev_Rec_Complete__c',ffrr__ActiveValue__c = 'True',
                                                  ffrr__IncludeActiveValue__c = 'Include', ffrr__Currency__c = 'CurrencyIsoCode',
                                                  ffrr__CompletedField__c = 'Rev_Rec_Complete__c', ffrr__CompletedValue__c = 'True', ffrr__IncludeCompletedValue__c = 'Exclude',
                                                  ffrr__RecognizedToDateValue__c = 'Recognized_to_Date_GAAP__c', ffrr__RevenueRecognitionCompleted__c = 'Rev_Rec_Complete__c',
                                                  ffrr__IncomeStatementAccount__c = 'x', ffrr__BalanceSheetAccount__c = 'x',
                                                  ffrr__FixedIncomeStatementAccountCode__c = true, ffrr__FixedBalanceSheetAccountCode__c = true));
        insert thirdLevelSettings;
        
        //List to hold Template records
        List<ffrr__Template__c> parentTemplates = new List<ffrr__Template__c>();
        
        //Creating Template record
        parentTemplates.add(new ffrr__Template__c(Name = 'ABC Revenue Line - GAAP', ffrr__RevRecType__c = 'Equal Split', ffrr__RevenueSource__c = 'ABC_Revenue_Line__c',
                                           ffrr__Settings__c = thirdLevelSettings[1].Id, ffrr__RevenueBasis__c = 'Total Revenue', 
                                           ffrr__CalculationType__c = 'Days'));
        insert parentTemplates;
        
        //List to hold Template records
        List<ffrr__Template__c> templates = new List<ffrr__Template__c>();
        
        //Creating Template record
        templates.add(new ffrr__Template__c(Name = 'ABC Revenue Line - Contract', ffrr__RevRecType__c = 'Equal Split', ffrr__RevenueSource__c = 'ABC_Revenue_Line__c',
                                           ffrr__Settings__c = thirdLevelSettings[0].Id, Template_A__c = parentTemplates[0].Id,
                                           ffrr__RevenueBasis__c = 'Total Revenue', ffrr__CalculationType__c = 'Days'));
        templates.add(new ffrr__Template__c(Name = 'ABC Revenue Line - S', ffrr__RevRecType__c = 'Equal Split', ffrr__RevenueSource__c = 'ABC_Revenue_Line__c',
                                           ffrr__Settings__c = secondLevelSettings[0].Id, Template_A__c = parentTemplates[0].Id,
                                           ffrr__RevenueBasis__c = 'Total Revenue', ffrr__CalculationType__c = 'Days'));
        insert templates;
        
        //List to hold product records
        List<Product2> products = new List<Product2>();
        
        //Creating Product records
        //8/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005222 - Removed Program_Family__c field
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 /*Program_Family__c = 'Higher Education',*/ Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = programs[0].Id, c2g__CODASalesTaxStatus__c = 'Taxable',
                                 Rev_Rec_Template__c = templates[0].Id));
        products.add(new Product2(Name = 'EDIT - IT Forum', ProductCode = 'EDIT',
                                 /*Program_Family__c = 'Higher Education',*/ Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = programs[1].Id, c2g__CODASalesTaxStatus__c = 'Taxable',
                                 Rev_Rec_Template__c = templates[0].Id));
        insert products;
    }
    
    /**
    *   Description     :   This method is used to test generateABCRevenues functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testGenerateABCRevenues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c, Payer_Account__c, 
                                       Program__c, End__c, Start__c, Setup_In_Negotiated__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        System.assert(ApexPages.getMessages() != null);
                
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.GENERATE_REVENUE_TERM_TYPE_MSG) {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        //Updating Contract ABC records
        contracts[0].Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM;
        contracts[0].Negotiated_Amount__c = null;
        update contracts;
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);

        //Reintilize the standard controller
        controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        System.assert(ApexPages.getMessages() != null);
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.GENERATE_LINES_MSG) {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        contracts[0].Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM;
        contracts[0].Negotiated_Amount__c = 500;
        contracts[0].Setup_in_Negotiated__c = 200;
        update contracts;
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Reintilize the standard controller
        controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        
        //Assertions
        System.assertNotEquals(null, controller.aBCrevenues);
        System.assertEquals(true, controller.hasAccess);
        
        //Stop testing here
        Test.stopTest();
        
        Util.BYPASS_DLRS_ABC_REVENUE_RECOGNITION_BATCH = true;
        update aBCRevenues[0];
        Util.BYPASS_DLRS_ABC_REVENUE_RECOGNITION_BATCH = false;
        
        Bypass_Logic__c bL = new Bypass_Logic__c();
        bL.Objects_to_Bypass__c = 'ALL';
        bL.Bypass_Triggers__c = true;
        bL.SetupOwnerId = UserInfo.getUserId();
        
        insert bl;
        update aBCRevenues[0];
    }
    
    /**
    *   Description     :   This method is used to test cloneABCRevenueFromContractABC functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testCloneABCRevenueFromContractABC(){
                
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == 'Unable to clone lines: Please select Contract ABC') {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Contract_ABC__c = contracts[0].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == 'Unable to clone lines: The selected source Contract record is same as main contract') {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Contract_ABC__c = contracts[1].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        System.assertEquals(4, controller.aBCrevenues.size());
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Contract_ABC__c = aBCRevenueLines[1].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.CLONE_LINES_MSG) {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        //Calling controller method
        controller.copyABCRevenueFromCurrentContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == 'Unable to Copy Lines because no record was selected.') {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(false, isMessageFound);
        System.assertEquals(6, controller.aBCrevenues.size());
        
        //Stop testing here
        Test.stopTest();
    }
    /**
    *   Description     :   This method is used to test copyABCRevenueFromCurrentContractABC and addBlankABCRevenue functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testCopyABCRevenueAndAddBlankLine(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();

        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller method
        controller.copyABCRevenueFromCurrentContractABC();
        
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == 'Unable to Copy Lines because no record was selected.') {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
       
        controller.aBCrevenues.clear();
        
        //Calling controller method
        controller.addBlankABCRevenue();
        System.assertEquals(3, controller.aBCrevenues.size());
        
        //Set controller variable
        controller.totalNewLines = '6';
        
        //Calling controller method
        controller.addBlankABCRevenue();
        System.assertEquals(9, controller.aBCrevenues.size());

        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test massEditABCRevenue, singleEditABCRevenue and removeABCRevenue functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testMassAndSingleEdit(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Editing ABC Revenue record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.Recognition_Start_Date__c = System.today().addDays(1);
        controller.aBCrevenues[0].selected = true;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Editing ABC Revenue Record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.Recognition_End_Date__c = System.today().addDays(2);
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Editing ABC Revenue Record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.Negotiated_Amount__c = 10;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Editing ABC Revenue Record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.Expected_Amount_to_Recognize__c = 200;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Editing ABC Revenue Record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.GAAP_Amount__c = 0;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Editing ABC Revenue Record
        controller.aBCrevenues[0].aBCRevenue.Rev_Rec_Complete__c = true;
        controller.revenuemManagementWrap.aBCRevenue.Secured_Amount__c = 0;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Updating controller variable
        controller.revenuemManagementWrap.selectedTemplate = null;
        controller.massEditABCRevenue();
        
        //Updating controller variable
        controller.aBCrevenues[0].selected = false;
        controller.massEditABCRevenue();
        
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail().contains('Please select atleast one record to update.')) {
                   isMessageFound = true;        
               }
        }
        System.assertEquals(true, isMessageFound);
        
        //Updating controller variable
        controller.revenuemManagementWrap = null;
        
        //Calling controller method
        controller.massEditABCRevenue();
        
        //Set controller variable. Passing index of record to eddit
        controller.revenueIndex = 0;
        controller.singleEditABCRevenue();
        
        System.assertEquals(2, controller.aBCrevenues.size());
        
        controller.revenueIndex = 1;
        controller.aBCrevenues[1].aBCRevenue.Id = null;
        controller.removeABCRevenue();
        System.assertEquals(1, controller.aBCrevenues.size());
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test doSave and saveAndClose functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testDoSave(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP',
                                          Line_Status__c = 'Pending', Recognition_Start_Date__c = System.today(),
                                          Recognition_End_Date__c = System.today().addDays(5), Fee_Type__c = 'Annual - Program',
                                          Negotiated_Amount__c = 200,Risk_Type__c = 'POC', Risk_Status__c = 'Pending',
                                          Risk_Due_Date__c = System.today().addDays(4)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c Order By Name ASC];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        //aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        //aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        //aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        //aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        //insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Enable all trigger
        Util.BypassAllTriggers = False;
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        ApexPages.getMessages().clear();
        Pagereference pg = controller.saveAndClose();
        System.assertNotEquals(null, pg);
        
        //Calling controller method
        controller.doSave();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            
            if(message.getDetail().contains('Please populate all the required fields')) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(True, isMessageFound);
        
        pg = controller.saveAndClose();
        //System.assertEquals(null, pg);
        
        //Re-initialize the controller
        controller = new RevenueManagementController();
        
        //Set controller variables
        controller.selectedOperation = 'CopyLines';
        List<SelectOption> operationOptions = controller.operationOptions;
        List<SelectOption> blankLines = controller.blankLines;
        
        //Set controller variable
        controller.totalNewLines = '1';
        controller.aBCrevenues[0].selectedTemplate = templates[2].Id;
        
        //Calling controller method
        controller.doSave();
        
        //Stop test here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test changeViewMode, placeHolder and aBCRevenueDetail functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void unitTest(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, contracts[0].Id);

        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller method
        controller.switchToManageMode();
        
        //Calling controller method
        controller.placeHolder();
        controller.revenueIndex = 0;
        controller.aBCRevenueDetail();
        System.assertEquals(0, controller.revenueHighlighIndex);
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test cloneABCRevenueFromContractABC functionalities for subscriptions
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testCloneABCRevenueFromSubscription() {
                
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
                
        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = 'Prospact', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                      SBQQ__Account__c = institute.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
    
        update opportunities;

        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'TT', Create_memberships__c = 'No'));
        insert programs;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Source_Opportunity__c = opportunities[0].Id, Program__c = programs[0].Id,
                                                Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;
	
		//Start testing from here
        Test.startTest();
        
        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;

        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == System.Label.UNABLE_TO_CLONE_SUBSCRIPTION_ERROR) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Program_Subscription__c = subscriptions[0].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == System.Label.UNABLE_TO_CLONE_SUBSCRIPTION_ERROR) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Program_Subscription__c = subscriptions[1].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        //System.assertEquals(4, controller.aBCrevenues.size());
        
        //Set controller variables
        controller.revenuemManagementWrap.aBCRevenue.Program_Subscription__c = aBCRevenueLines[1].Id;
        
        //Calling controller class method
        controller.cloneABCRevenueFromContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.CLONE_LINES_MSG) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
        
        //Calling controller method
        controller.copyABCRevenueFromCurrentContractABC();
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == 'Unable to Copy Lines because no record was selected.') {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(false, isMessageFound);
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test generateABCRevenues functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testGenerateABCRevenuesSubscription(){
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = 'Prospact', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;

        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                      SBQQ__Account__c = institute.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
    
        update opportunities;
        
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'TT', Create_memberships__c = 'No'));
        insert programs;
		
	//Start testing from here
        Test.startTest();
        

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                  Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                  Source_Opportunity__c = opportunities[0].Id, Program__c = programs[0].Id,
                                                  Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;

        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM,
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,Setup_in_Negotiated__c = 9,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;

        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        //System.assert(ApexPages.getMessages() != null);
                
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.GENERATE_REVENUE_TERM_TYPE_MSG) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
        
        //Updating Contract ABC records
        subscriptions[0].Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM;
        subscriptions[0].Negotiated_Amount_Subscription__c = null;
        update subscriptions;
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);

        //Reintilize the standard controller
        controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        //System.assert(ApexPages.getMessages() != null);
        
        //Get page messages
        pageMessages = ApexPages.getMessages();
        isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == Label.GENERATE_LINES_MSG) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
        
        subscriptions[0].Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM;
        subscriptions[0].Negotiated_Amount_Subscription__c = 500;
        //subscriptions[0].Setup_in_Negotiated__c = 200;
        update subscriptions;
        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);
        
        //Reintilize the standard controller
        controller = new RevenueManagementController();
        
        //Calling controller class method
        controller.generateABCRevenues();
        controller.checkABCRevenueCreatedOnProgramSubscription();
        controller.generateABCRevenueForStandardContract();
       
        //Assertions
        //System.assertNotEquals(null, controller.aBCrevenues);
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test copyABCRevenueFromCurrentContractABC and addBlankABCRevenue functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testCopyABCRevenueAndAddBlankLineSubscription(){
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = 'Prospact', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                      SBQQ__Account__c = institute.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
    
        update opportunities;
		
		//Start testing from here
        Test.startTest();


        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'TT', Create_memberships__c = 'No'));
        insert programs;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Source_Opportunity__c = opportunities[0].Id, Program__c = programs[0].Id,
                                                Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;
		
        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;

        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller method
        controller.copyABCRevenueFromCurrentContractABC();
        
        //Get page messages
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail() == System.Label.UNABLE_TO_COPY_LINES_ERROR) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(true, isMessageFound);
       
        controller.aBCrevenues.clear();
        
        //Calling controller method
        controller.addBlankABCRevenue();
        //System.assertEquals(3, controller.aBCrevenues.size());
        
        //Set controller variable
        controller.totalNewLines = '6';
        
        //Calling controller method
        controller.addBlankABCRevenue();
        //System.assertEquals(9, controller.aBCrevenues.size());

        //Stop testing here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test doSave and saveAndClose functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testDoSaveSubscription() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();
	//Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = 'Prospact', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                      SBQQ__Account__c = institute.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
		
		//Start testing from here
        Test.startTest();
        
        update opportunities;

        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'TT', Create_memberships__c = 'No'));
        insert programs;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Source_Opportunity__c = opportunities[0].Id, Program__c = programs[0].Id,
                                                Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;

        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;

        
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);
        
        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        ApexPages.getMessages().clear();
        Pagereference pg = controller.saveAndClose();
        //System.assertNotEquals(null, pg);
        
        //Calling controller method
        controller.doSave();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Boolean isMessageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            
            if(message.getDetail().contains(System.Label.PLEASE_POPULATE_ALL_REQUIRED_FIELDS_ERROR)) {
                   isMessageFound = true;        
               }
        }
        //System.assertEquals(True, isMessageFound);
        
        pg = controller.saveAndClose();
        //System.assertEquals(null, pg);
        
        //Re-initialize the controller
        controller = new RevenueManagementController();
        
        //Set controller variables
        controller.selectedOperation = 'CopyLines';
        List<SelectOption> operationOptions = controller.operationOptions;
        List<SelectOption> blankLines = controller.blankLines;
        
        //Set controller variable
        controller.totalNewLines = '1';
        controller.aBCrevenues[0].selectedTemplate = templates[2].Id;
        controller.aBCrevenues[0].aBCRevenue.Line_Status__c = 'Pending';
        controller.aBCrevenues[0].aBCRevenue.Recognition_Start_Date__c = System.today();
        controller.aBCrevenues[0].aBCRevenue.Recognition_End_Date__c = System.today();
        controller.aBCrevenues[0].aBCRevenue.Fee_Type__c = 'Annual';
        controller.aBCrevenues[0].aBCRevenue.Negotiated_Amount__c = 0.00;
        controller.aBCrevenues[0].aBCRevenue.Risk_Type__c = 'none';
        controller.aBCrevenues[0].aBCRevenue.Expected_Amount_to_Recognize__c = 0.00;
        controller.aBCrevenues[0].aBCRevenue.Secured_Amount__c = 0.00;
        controller.aBCrevenues[0].aBCRevenue.Secured_Amount_GAAP__c = 0.00;
        controller.aBCrevenues[0].errorMessage = null;
        controller.aBCrevenues[0].aBCRevenue.Change_Reason_Code_Clone__c = 'Test';
        
        //Calling controller method
        controller.doSave();
        
        //Stop test here
        Test.stopTest();
    }
    
    /**
    *   Description     :   This method is used to test changeViewMode, placeHolder and aBCRevenueDetail functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void unitTestSubscription(){
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];

        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = 'Prospact', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                      SBQQ__Account__c = institute.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = CPQConstants.OPP_STAGE_SENT_TO_BOOKED;
		
		//Start testing from here
        Test.startTest();
        
		
        update opportunities;

        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'TT', Create_memberships__c = 'No'));
        insert programs;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Source_Opportunity__c = opportunities[0].Id, Program__c = programs[0].Id,
                                                Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;
        

        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Term_Type__c = RMConstants.CONTRACT_ABC_FIXED_TERM,
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,Setup_in_Negotiated__c = 5,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Previous_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed');
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id,GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscriptions[1].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000));
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
        
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        insert aBCRevenueLines;

        //Stop testing here
        Test.stopTest();
       
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, subscriptions[0].Id);

        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        //Calling controller method
        controller.switchToManageMode();
        
        //Calling controller method
        controller.placeHolder();
        controller.revenueIndex = 0;
        controller.aBCRevenueDetail();
        controller.switchToViewMode();
        controller.populateClarizenValue();
        //System.assertEquals(0, controller.revenueHighlighIndex);
        
        
        ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = true;
        try {
            update aBCRevenues[0];
    
        }catch(Exception e) {
            ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = false;
        }
    }
    
    /**
    *   Description     :   This method is used to test changeViewMode, placeHolder and aBCRevenueDetail functionalities
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void unitTestSubscription1(){
       
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        Contract conrt = new Contract();
        conrt.Name = 'Tesrt';
        conrt.AccountId = institute.Id;
        insert conrt;
         
        //Setting URL parameters
        Test.setCurrentPageReference(Page.RevenueManagement);
        System.currentPageReference().getParameters().put(RMConstants.URL_PARAM_PARENTID, conrt.Id);

        //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        controller.depClarizenValue  = system.today();
    }    
    
    static testMethod void test_checkABCRevenueCreatedOnProgramSubscription() 
    {
        Util.byPassAllTriggers = true;
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education');
        
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        insert accounts;
        
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', AccountId = accounts[0].Id, Employee_ID__c = '12346'));
        insert contacts;
        
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        insert quotes;
        
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), 
                                   ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                                   SBQQ__Quote__c = quotes[0].Id));
        insert contracts;
        
        Id ProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(new SBQQ__Subscription__c (SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0, SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, 
                                                     SBQQ__ProrateMultiplier__c = 2, Status__c = 'Committed', RecordTypeId = ProgramRecordType,
                                                     SBQQ__Contract__c = contracts[0].Id));
        Util.byPassAllTriggers = false;
        
        Test.startTest();
          //Initialization the controller
        RevenueManagementController controller = new RevenueManagementController();
        
        controller.checkABCRevenueCreatedOnProgramSubscription();
        
        Test.stopTest();
    }
}