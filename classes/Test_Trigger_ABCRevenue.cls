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
private class Test_Trigger_ABCRevenue {
    
    /**
    *   Description     :   Testing for Trigger_ABCRevenue trigger and it's helper class
    *
    *   Created by      :   Saurabh Kumar
    *
    *   Created Date    :   02/14/2017
    *
    *   Revision Log    :   V1.0 - Created - CR-20161102-10316
    *			    V1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    *   		    V1.2 - Modified By - Neha Sharma - 09/03/2021 - CR-20201217-14749 - Test Class Coverage
    *			    V1.3 - Modified By - Nikita Kumari - 11/10/2021 - CR-20210908-15415 - Added validateTemplateBasedFields method
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
        
        //Creating Opportunity records
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp1', StageName = 'Phone Appointment Scheduled', CloseDate = System.today().addDays(30)));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp2', StageName = 'Proposal In Progress', CloseDate = System.today().addDays(30)));
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
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test2', AccountId = accounts[0].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test3', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A', 
                                 Email='dummyemail@testemail.com', Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test4', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        insert contacts;
        
        //List to hold Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Creating Contract ABC Records
        contracts.add(new Contract__c(Name = 'Test ContractABC1', Payer_Account__c = accounts[0].Id, Source_Opportunity__c = opportunities[0].Id, 
                                      Program__c = programs[0].Id,  Invoicing_Arrangement__c = 'Annual', Main_Contact__c = contacts[0].Id,
                                      Invoice_Contact__c = contacts[1].Id, Year__c = '2016', Type__c = 'NBB', Start__c = System.today().addDays(-15),
                                      End__c = System.today().addDays(+10), Status__c = 'Pending', Term_Type__c = 'Opt Out', Years_in_Term__c = 2,
                                      Contract_Count__c = 2, Contract_Currency__c = 'EUR - Euro', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        contracts.add(new Contract__c(Name = 'Test ContractABC2', Payer_Account__c = accounts[1].Id, Source_Opportunity__c = opportunities[1].Id, 
                                      Program__c = programs[1].Id,  Invoicing_Arrangement__c = 'Semi-Annual', Main_Contact__c = contacts[2].Id,
                                      Invoice_Contact__c = contacts[3].Id, Year__c = '2017', Type__c = 'Renewal', Start__c = System.today().addDays(-5),
                                      End__c = System.today().addDays(10), Status__c = 'Void', Term_Type__c = 'Fixed Term', Years_in_Term__c = 3,
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
        insert thirdLevelSettings;
        
        //List to hold Template records
        List<ffrr__Template__c> templates = new List<ffrr__Template__c>();
        
        //Creating Template record
        templates.add(new ffrr__Template__c(Name = 'ABC Revenue Line - Contract', ffrr__RevRecType__c = 'Equal Split', ffrr__RevenueSource__c = 'ABC_Revenue_Line__c',
                                           ffrr__Settings__c = thirdLevelSettings[0].Id, ffrr__RevenueBasis__c = 'Total Revenue', 
                                           ffrr__CalculationType__c = 'Days'));
        insert templates;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  /*recordTypes[0].Id*/, 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        //insert
        insert subscriptions;
        
        //List to hold component suscription
        List<SBQQ__Subscription__c> compSubscriptions = new List<SBQQ__Subscription__c>();
        
        //Add new subscription record in list
        compSubscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, Program_Subscription__c = subscriptions[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,Official_Drop_Date__c = Date.today()));
        
        //insert
        insert compSubscriptions;
        
        Project__c project = new Project__c(Name = 'Testing', Institution__c = accounts[0].Id);
        
        //Deployment record
        List<Deployment__c> deployments = new List<Deployment__c>();
        
        deployments.add(new Deployment__c(Name = 'Test_Deployment', Program__c = programs[0].Id));
        
        //Insert
        insert deployments;
        
    }
    
    /**
    *   Description     :   This method is used to test syncABCRevenuesAndTheirChildren method of ABCRevenueTriggerHelper class
    *
    *   @args           :   
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - CR-20161102-10316
    **/
    static testMethod void testSyncABCRevenuesAndTheirChildren(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List of accounts
        List<Account> accounts = [Select Id From Account Order By Name ASC];
        
        //List of Program Subscription
        List<SBQQ__Subscription__c> progSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program'];
        
        //List of Component Subscription
        List<SBQQ__Subscription__c> compSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Component'];
        
        // Create Project
        Project__c project = TestUtilities.createProject(false);
        project.Institution__c = accounts[0].Id;
        insert project;
        
        system.assert(project.Id != null);
        
        //List of Deployment
        List<Deployment__c> deployments = [Select Id, Name, Program__c From Deployment__c];
        deployments[0].RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('APS Deployment').getRecordTypeId();
        deployments[0].Project__c = project.Id;
        deployments[0].Deployment_Phase__c = '0 - Planning';
        deployments[0].Non_Revenue__c = false;
        update deployments;
        
        //Assertions
        System.assert(contracts != null);
        System.assertEquals(2, contracts.size());
        System.assertEquals(null, contracts[0].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[0].GAAP_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].GAAP_Amount_RevRec__c);
        System.assertEquals(2, accounts.size());
        System.assertEquals(1, progSubs.size());
        System.assertEquals(1, compSubs.size());
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, Program_Subscription__c = progSubs[0].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-5), 
                                           Recognition_End_Date__c = System.today().addDays(5), Expected_Amount_to_Recognize__c = 100,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 0, Rev_Rec_Complete__c = true,
                                           Site_Live_Date__c = System.today(), Change_Reason_Code__c = 'Site Live Date Achieved', Line_Status__c = 'Pending'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-4),
                                           Recognition_End_Date__c = System.today().addDays(4), Expected_Amount_to_Recognize__c = 200,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 1000, Rev_Rec_Complete__c = true,
                                           Site_Live_Date__c = System.today(), Change_Reason_Code__c = 'Site Live Date Achieved', Line_Status__c = 'Reviewed'));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-3),
                                           Recognition_End_Date__c = System.today().addDays(3), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 200, Secured_Amount__c = 200, GAAP_Amount__c = 1000, Program_Subscription__c = progSubs[0].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Rev_Rec_Complete__c = true));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 0, Secured_Amount__c = 0, GAAP_Amount__c = 0.0));
        
        //Bypass Trigger
        insert aBCRevenues;
        
        //Query on templates
        List<ffrr__Template__c> templates = [Select Id From ffrr__Template__c];
        System.assert(templates != null);
            
        //List to hold ABC Revenue Line
        List<ABC_Revenue_Line__c> aBCRevenueLines = new List<ABC_Revenue_Line__c>();
        
        //Creating ABC Revenue Line records
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A1', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A2', ABC_Revenue__c = aBCRevenues[0].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A3', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A4', ABC_Revenue__c = aBCRevenues[1].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A5', ABC_Revenue__c = aBCRevenues[2].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A6', ABC_Revenue__c = aBCRevenues[3].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A7', ABC_Revenue__c = aBCRevenues[4].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A8', ABC_Revenue__c = aBCRevenues[4].Id, ffrrtemplate__c = templates[0].Id, Rev_Rec_Complete__c = true));
        aBCRevenueLines.add(new ABC_Revenue_Line__c(Name = 'RR-00000055-A9', ABC_Revenue__c = aBCRevenues[4].Id, ffrrtemplate__c = templates[0].Id));
        
        insert aBCRevenueLines;
        
        //Start testing from here
        Test.startTest();
        
        //Adding this method as it is not called from trigger
        //Modified by Mahendra Swarnkar - 01-08-2019 - CR-20191122-13532 - End Here
        List<Id> progSubIds = new List<Id>();
        for(SBQQ__Subscription__c sub : progSubs){
            progSubIds.add(sub.Id);
        }
        ABCRevenueTriggerHelper.checkForRevenueRecords(progSubIds);
        //Modified by Mahendra Swarnkar - 01-08-2019 - CR-20191122-13532 - End Here
        
        //Update ABC Revenue
        aBCRevenues[0].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[1].Recognition_Start_Date__c = System.today().addDays(-2);
        aBCRevenues[1].Recognition_End_Date__c = System.today().addDays(4);
        aBCRevenues[1].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[2].Negotiated_Amount__c = 600;
        aBCRevenues[2].Secured_Amount__c = 600;
        aBCRevenues[2].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[3].Expected_Amount_to_Recognize__c = 300;
        aBCRevenues[3].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[4].GAAP_Amount__c = 100;
        aBCRevenues[4].Negotiated_Amount__c = 350;
        aBCRevenues[4].Secured_Amount__c = 350;
        aBCRevenues[4].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[5].Change_Reason_Code_Clone__c = 'Reallocation';
        aBCRevenues[5].Integrated_Account_Name__c = accounts[1].Id;
        aBCRevenues[5].Program_Subscription__c = progSubs[0].Id;
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        update aBCRevenues;
        
        //Query on ABC Revenue to get updated records
        aBCRevenues = [Select Id, Rev_Rec_Complete__c, Line_Status__c From ABC_Revenue__c Order By Name ASC];
        
        //Assertions
        System.assert(aBCRevenues != null);
        System.assertEquals(true, aBCRevenues[0].Rev_Rec_Complete__c);
        System.assertEquals(null, aBCRevenues[0].Line_Status__c);
        System.assertEquals(false, aBCRevenues[1].Rev_Rec_Complete__c);
        System.assertEquals(false, aBCRevenues[2].Rev_Rec_Complete__c);
        System.assertEquals(false, aBCRevenues[3].Rev_Rec_Complete__c);
        System.assertEquals(false, aBCRevenues[4].Rev_Rec_Complete__c);
        System.assertEquals(False, aBCRevenues[5].Rev_Rec_Complete__c);
        System.assertEquals(null, aBCRevenues[5].Line_Status__c);
        
        //Query on ABC Revenue Line to get updated records
        aBCRevenueLines = [Select Id, Rev_Rec_Complete__c, Line_Status__c From ABC_Revenue_Line__c Order By Name ASC];

        //Assertions
        System.assert(aBCRevenueLines != null);
        System.assertEquals(true, aBCRevenueLines[0].Rev_Rec_Complete__c);
        System.assertEquals(null, aBCRevenueLines[0].Line_Status__c);
        System.assertEquals(true, aBCRevenueLines[1].Rev_Rec_Complete__c);
        System.assertEquals(null, aBCRevenueLines[1].Line_Status__c);
        //System.assertEquals(false, aBCRevenueLines[2].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[3].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[4].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[5].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[6].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[7].Rev_Rec_Complete__c);
        //System.assertEquals(false, aBCRevenueLines[8].Rev_Rec_Complete__c);
        
        //Stop testing here
        Test.stopTest();
        
        ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = true;
        try {
        	update aBCRevenues[0];
    
        }catch(Exception e) {
            ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = false;
        }
    }
    
    /**
    *   Description     :   This method is used to test validation
    *
    *   @args           :   None
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - Mahendra Swarnakar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue
    **/
    static testMethod void testValidationOnABCRevenues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List of accounts
        List<Account> accounts = [Select Id From Account Order By Name ASC];
        
        //List of Program Subscription
        List<SBQQ__Subscription__c> progSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program'];
        
        //List of Component Subscription
        List<SBQQ__Subscription__c> compSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Component'];
        
        //List of Deployment
        List<Deployment__c> deployments = [Select Id, Name, Program__c From Deployment__c];
        
        //Assertions
        System.assert(contracts != null);
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 100, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, Program_Subscription__c = progSubs[0].Id,
                                           Deployment__c = deployments[0].Id, Site_Live_Date__c = System.today()));
        
        //Added By - Neha Sharma - 09/03/2021 - CR-20201217-14749 - Test Class Coverage
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 50, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, Program_Subscription__c = progSubs[0].Id,
                                           Deployment__c = deployments[0].Id, Change_Reason_Code_Clone__c = 'Reallocation'));
        
        //Bypass all triggers
        Util.BypassAllTriggers = false;
        
        //insert revenue
        insert aBCRevenues;
        
        test.startTest();
        
        ABC_Revenue__c revenue = [Select Id , Site_Live_Date__c FROM ABC_Revenue__c Where Negotiated_Amount__c = 100 limit 1];
        
        //Add By - Neha Sharma - 09/03/2021 - CR-20201217-14749 - Test Class Coverage
        ABC_Revenue__c revenue1 = [Select Id , Site_Live_Date__c FROM ABC_Revenue__c Where Negotiated_Amount__c = 50 limit 1];
        
        //after insert case
        System.assertEquals(System.today(), revenue.Site_Live_Date__c);
        
        //update case
        revenue.Deployment__c = null;
        
        //Add By - Neha Sharma - 09/03/2021 - CR-20201217-14749 - Test Class Coverage
        revenue1.Site_Live_Date__c = System.today();
        //update revenue
        Update revenue;
        
        //Add By - Neha Sharma - 09/03/2021 - CR-20201217-14749 - Test Class Coverage
        Update revenue1;
        
        revenue = [Select Id , Site_Live_Date__c FROM ABC_Revenue__c limit 1];
        //after update
        System.assertEquals(null, revenue.Site_Live_Date__c);
        
        test.stopTest();
    }
    
    static testMethod  void test_populateSiteLiveOnABCRevenue(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
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
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee', Family = 'Enrollment Services',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Travel Fee', IsActive = true, ProductCode = 'TravelFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Travel Fee', Program_Name_Member_Facing__c = 'Travel Fee', Family = 'Enrollment Services',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Offer', IsActive = true, ProductCode = 'Offer', SBQQ__Component__c = true,Offer__c = true,
                                  Product_Category__c = 'Offer', Program_Name_Member_Facing__c = 'Offer', Family = 'Enrollment Services',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List of accounts
        List<Account> accounts = [Select Id From Account Order By Name ASC];
        accounts[0].RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        accounts[1].RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        update accounts;
        System.assert(accounts.size() == 2);
        
        //List of Program Subscription
        List<SBQQ__Subscription__c> progSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program'];
        progSubs[0].SBQQ__Product__c = products[0].Id;
        update progSubs;
        System.assert(progSubs.size() == 1);
        
        //List of Component Subscription
        List<SBQQ__Subscription__c> compSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Component'];
        System.assert(compSubs.size() == 1);
        //List of Deployment
        List<Deployment__c> deployments = [Select Id, Name, Program__c From Deployment__c];
        
        //Assertions
        System.assert(contracts != null);
        System.assertEquals(2, contracts.size());
        System.assertEquals(null, contracts[0].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[0].GAAP_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].GAAP_Amount_RevRec__c);
        System.assertEquals(2, accounts.size());
        System.assertEquals(1, progSubs.size());
        System.assertEquals(1, compSubs.size());
        
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(Name = 'Testing', Institution__c = accounts[0].Id, Product2__c = products[0].Id, Fiscal_Year__c = String.valueOf(System.today().Year())));
        insert projects;
        System.assert(projects.size() == 1);
        
        // Insert Job_Ticket__c
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Vendor_Type__c='Offset', Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = UserInfo.getUserId(), 
                                         Project__c = projects[0].id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(), Mail_Vendor__c = accounts[0].Id,
                                         Production_Manager__c = UserInfo.getUserId(),of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = String.valueOf(System.today().Year()), Program__c = programs[0].Id));
        
        insert jobTickets;

        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        update jobTickets;
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2), Institution__c = accounts[0].Id,
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250, Product__c = products[0].Id,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, Program_Subscription__c = progSubs[0].Id,
                                           Revenue_Start_Date_Override__c = System.today().addDays(2)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-5), 
                                           Recognition_End_Date__c = System.today().addDays(5), Expected_Amount_to_Recognize__c = 100, Institution__c = accounts[0].Id,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 0, Rev_Rec_Complete__c = true,Product__c = products[1].Id,
                                           Site_Live_Date__c = System.today(), Change_Reason_Code__c = 'Site Live Date Achieved', Line_Status__c = 'Pending',
                                           Integrated_Account_Name__c = accounts[0].Id, Program_Subscription__c = progSubs[0].Id,
                                            Revenue_Start_Date_Override__c = System.today().addDays(1)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-4), Institution__c = accounts[0].Id,
                                           Recognition_End_Date__c = System.today().addDays(4), Expected_Amount_to_Recognize__c = 200, Product__c = products[2].Id,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 1000, Rev_Rec_Complete__c = true,
                                           Site_Live_Date__c = System.today(), Change_Reason_Code__c = 'Site Live Date Achieved', Line_Status__c = 'Reviewed',
                                           Integrated_Account_Name__c = accounts[0].Id, Program_Subscription__c = progSubs[0].Id,
                                           Revenue_Start_Date_Override__c = System.today().addDays(1)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-3), Institution__c = accounts[0].Id,
                                           Recognition_End_Date__c = System.today().addDays(3), Expected_Amount_to_Recognize__c = 250, Product__c = products[0].Id,
                                           Negotiated_Amount__c = 200, Secured_Amount__c = 200, GAAP_Amount__c = 1000, Program_Subscription__c = progSubs[0].Id,
                                           Integrated_Account_Name__c = accounts[1].Id, Revenue_Start_Date_Override__c = System.today().addDays(2)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2), Product__c = products[1].Id,
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250, Institution__c = accounts[0].Id,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Rev_Rec_Complete__c = true,
                                           Program_Subscription__c = progSubs[0].Id, Revenue_Start_Date_Override__c = System.today().addDays(2)));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2),Product__c = products[1].Id,
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250, Institution__c = accounts[0].Id,
                                           Negotiated_Amount__c = 0, Secured_Amount__c = 0, GAAP_Amount__c = 0.0, Program_Subscription__c = progSubs[0].Id,
                                           Revenue_Start_Date_Override__c = System.today().addDays(2)));
        
		
	Test.startTest();
        
        Util.byPassAllTriggers = false;
        insert aBCRevenues;
        
        List<ABC_Revenue__c> rev = [Select Id, Job_Ticket__c, Project__c, Site_Live_Date__c From ABC_Revenue__c Where Job_Ticket__c != null];
        System.assertEquals(2, rev.size());
        Test.stopTest();
        
    }
    
    /**
    *   Description     :   This method is used to test validation for Templates
    *
    *   @args           :   None
    *
    *   @return type    :   Void
    *
    *   @Revision Log   :   V1.0 Created - Mahendra Swarnakar - 01/05/2021 - CR-20210908-15415 - Validation Rule for Deployments on revenue
    **/
    static testMethod void testValidateTemplateBasedFields(){
                
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Query to fetch Contract ABC  Records
        List<Contract__c> contracts = [Select Id, Name, Negotiated_Amount_RevRec__c, GAAP_Amount_RevRec__c From Contract__c Order By Name ASC];
        
        //List of accounts
        List<Account> accounts = [Select Id From Account Order By Name ASC];
        
        //List of Program Subscription
        List<SBQQ__Subscription__c> progSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program'];
        
        //List of Component Subscription
        List<SBQQ__Subscription__c> compSubs = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Component'];
        
        // Create Project
        Project__c project = TestUtilities.createProject(false);
        project.Institution__c = accounts[0].Id;
        insert project;
        
        system.assert(project.Id != null);
        
        //List of Deployment
        List<Deployment__c> deployments = [Select Id, Name, Program__c From Deployment__c];
        deployments[0].RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('APS Deployment').getRecordTypeId();
        deployments[0].Project__c = project.Id;
        deployments[0].Deployment_Phase__c = '0 - Planning';
        deployments[0].Non_Revenue__c = false;
        update deployments;
        
        //Assertions
        System.assert(contracts != null);
        System.assertEquals(2, contracts.size());
        System.assertEquals(null, contracts[0].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[0].GAAP_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].GAAP_Amount_RevRec__c);
        System.assertEquals(2, accounts.size());
        System.assertEquals(1, progSubs.size());
        System.assertEquals(1, compSubs.size());
        
        
        List<Revenue_Template_Related_Field_Mapping__mdt> templateFieldsMapping = new List<Revenue_Template_Related_Field_Mapping__mdt>([SELECT ID, IsActive__c, Revenue_Field_API_Name__c, 
                                                                                                                                         Revenue_Field_Label__c, Source_Object_API_Name__c,
                                                                                                                                         Target_Object_API_Name__c,
                                                                                                                                         Template_Id__c,Template_Name__c
                                                                                                                                         FROM Revenue_Template_Related_Field_Mapping__mdt
                                                                                                                                         WHERE Source_Object_API_Name__c = 'ABC_Revenue__c' 
                                                                                                                                         AND IsActive__c = true
                                                                                                                                         AND Revenue_Field_API_Name__c != null
                                                                                                                                         AND Template_Id__c != '']);
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, 
                                           Program_Subscription__c = progSubs[0].Id, Rev_Rec_Template_Selected__c = templateFieldsMapping[0].Template_Id__c));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, 
                                           Rev_Rec_Complete__c = true, Integrated_Account_Name__c = accounts[1].Id, 
                                           Program_Subscription__c = progSubs[0].Id, Rev_Rec_Template_Selected__c = templateFieldsMapping[0].Template_Id__c));
        //Bypass all triggers
        Util.BypassAllTriggers = false;
         
        //Start testing from here
        Test.startTest();
        
        try{
            ABCRevenueTriggerHelper.validateTemplateBasedFields(aBCRevenues, null);
        }
        catch(Exception ex)
        {
            System.assertEquals(true, String.isNotBlank(ex.getMessage()));
            System.assertEquals(true, ex.getMessage().contains(System.Label.Rev_Template_Error_Message));
        }
        Test.stopTest();
              
    }
}