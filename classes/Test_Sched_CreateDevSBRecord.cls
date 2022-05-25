/**
*   Purpose         :   Test class for Sched_CreateDevSBRecord
*            
*   Create By       :   Mahendar Swarnkar
* 
*   Created Date    :   09/07/2021
*
*   Revision Log    :   V_1.0 - Created - CR-20210901-15400 - PrintMIS OE/BRE Test Data Create Utility
*   
*   Coverage        :   
*
**/
@isTest(seeAllData = false)       
private class Test_Sched_CreateDevSBRecord 
{
    @testSetup static void dataSetup() 
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[0].Status__c = 'Active';
        programs[0].Name = 'Test Program CAM';
        programs[0].Program_Acronym__c = 'ESAM';
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
        
        //Add additional field values
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[1].Status__c = 'Active';
        programs[1].Name = 'Test Program CAM';
        programs[1].Program_Acronym__c = 'ESAMESIP';
        programs[1].Program_Formal_Name__c = 'Test Method';
        programs[1].Renewable__c = true; 
        programs[1].New_Business_Business__c = 'EAB';
        programs[1].Type__c = 'Standard';
        programs[1].Type__c = 'Standard';
        programs[1].New_Business_Vertical__c = 'EAB';
        programs[1].Entity__c = 'EAB';
        programs[1].Program_Line__c = 'PT';
        programs[1].Sector__c = 'HE';
        programs[1].Applicable_Segments__c = 'International Education;US Education';
        programs[1].Solomon_Code__c = '851';
        programs[1].New_Business_Marketer__c = 'HE SSC';
        programs[1].Create_memberships__c = 'Yes';
        programs[1].Renewal_Unit_Count__c = 1;

        //Insert
        insert programs;
        
        Product2 topParent = new Product2(Name = 'Test Top Parent', Family = 'EAB Tech', IsActive = true,
                                  ProductCode = 'ESAMTopParent', SBQQ__Component__c = true, Program_Name_Member_Facing__c = 'Test Custom Application Marketing',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        insert topParent; 
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'Test Custom Application Marketing', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'ESAM', SBQQ__Component__c = true, Program_Name_Member_Facing__c = 'Test Custom Application Marketing',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1, Parent_Product__c = topParent.Id,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Test Inquiry Pool – Custom App Marketing', IsActive = true, Program__c = programs[1].Id, ProductCode = 'ESAMESIP',
                                  SBQQ__Component__c = true, Program_Name_Member_Facing__c = 'Test Inquiry Pool – Custom App Marketing',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,Parent_Product__c = topParent.Id,
                                 SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Test Program Cost', IsActive = true, ProductCode = 'ESAMPROGRAMCOST',  SBQQ__Component__c = true,
                                  //Program__c = programs[0].Id,
                                  Program_Name_Member_Facing__c = 'Test Program Cost', Product_Category__c = 'Annual Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                 SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        //Insert
        insert products;
            
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Test Custom Application', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Test Inquiry Pool', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[1].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productOptions;
        
        //List of PriceBookEntry
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        
        //Insert test data of price  book entry
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice = 0.00 ,Isactive = true, CurrencyIsoCode = 'USD'));
        priceBookEntries.add(new PricebookEntry(Product2Id = products[1].Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice = 0.00, Isactive = true, CurrencyIsoCode = 'USD'));
        priceBookEntries.add(new PricebookEntry(Product2Id = products[2].Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice = 0.00, Isactive = true, CurrencyIsoCode = 'USD'));
        
        //insert
        insert priceBookEntries;
        
        SBQQ__Dimension__c programCostPriceDimension = new SBQQ__Dimension__c(Name = 'Yearly', SBQQ__Type__c = 'Year', SBQQ__Product__c = products[2].Id);
        
        insert programCostPriceDimension;
        
        Account vendor = new Account(Name = 'Darwil', Account_Formal_Name__c = 'Darwill', recordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Vendor_Sub_Type__c = 'Digital',  Status__c = 'Active');
        
        insert vendor;
        
        Util.byPassAllTriggers = false;
    }
    
    //V1.0 - Created - CR-20210901-15400 - test PrintDataUtilityWrapper class
    @isTest static void testSched_CreateDevSBRecord() 
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Product2> products = [Select Id, Name, ProductCode From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
        
        List<Account> listAccount = [Select ID from Account];
        system.assertEquals(1, listAccount.size());
        
        Map<Integer, Id> mapCounterWithRecordId;
        
        Integer currentIndex;
        
        Map<String, ID> mapUniqueKeyWithRecordId;
        
        Set<Id> quoteLineRecordIds;
        
        List<sObject> approvedByPartnerRecords;
        
        String uniquePrintData;
		
	PrintDataUtilityWrapper pWrapper = new PrintDataUtilityWrapper();
        
        //Inventory Transaction Fields
        pWrapper.IT_Print_Vendor = listAccount[0].Id;
        pWrapper.IT_Mail_Vendor = listAccount[0].Id;
        
        //Job Ticket Fields
        pWrapper.JT_Drop_Type = 'Pre Planned';
        pWrapper.JT_Vendor_Type = 'Digital';
        pWrapper.JT_Mail_Vendor = listAccount[0].Id;
        pWrapper.JT_No_Of_Drop  = 2;
        pWrapper.JT_Project_ID  = '15254';

        
        //List of user emails for send final mail
        pWrapper.emailList = new List<String>{'test.junkeab@eab.com'};
        
        DateTime sysTime = dateTime.now().addMinutes(5);
        
        //Cron Expression
        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Test start from Here
        Test.startTest();
        
        //Test the Accounts Insert
        Sched_CreateDevSBRecord scheduleJob = new Sched_CreateDevSBRecord(pWrapper);
        
        //Schedule 
        System.schedule('Sched_CreateDevSBRecord', cronExpr , scheduleJob);
        
        //Test stop Here
        Test.stopTest();
    }

    
    static testMethod void  test_createUtilityRecords1()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Product2> products = [Select Id, Name, ProductCode From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
        
        List<Account> listAccount = [Select ID from Account];
        system.assertEquals(1, listAccount.size());
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 1;
        String uniquePrintData = JSON.serialize(getPrintWrapperData(listAccount[0]));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            quoteLineRecordIds.add(createDevData.Id);
        }
        
        Test.startTest();
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
        
        // Create contact data
        currentIndex++;
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
        
        // Create opportunity data
        currentIndex++;
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
        Test.stopTest(); 
        
		if(!Util.IS_PRODUCTION_INSTANCE)
		{
			List<Account> accounts = [Select ID, Name From Account Where Name like 'Test OE/BRE Utility%'];
			System.assertEquals(1, accounts.size());
			
			List<Contact> contacts = [Select ID From Contact where AccountId = :accounts[0].Id];
			System.assertEquals(1, contacts.size());
			
			List<Opportunity> opp = [Select Id From Opportunity where AccountId = :accounts[0].Id AND Main_Contact__c = :contacts[0].Id];
			System.assertEquals(1, opp.size());
		}
        
        
    }
    
    //Method to test insertion of SBQQ__Quote__c
    static testMethod void  test_createUtilityRecords2()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        insert opp;
        System.assert(opp.Id != null);
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 5;// index for SBQQ__Quote__c
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        
        Test.startTest();
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
        Test.stopTest();
        
        List<SBQQ__Quote__c> quote = [Select Id From SBQQ__Quote__c Where SBQQ__Opportunity2__c =:opp.Id AND SBQQ__PrimaryContact__c =: contact.Id];
        System.assertEquals(1, quote.size());
    }
    
    //Method to test insertion of SBQQ__QuoteLine__c order1
    static testMethod void  test_createUtilityRecords3()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        // query products	
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
              
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 5;// 5 index for SBQQ__QuoteLine__c
                
        PrintDataUtilityWrapper pWrapper = getPrintWrapperData(account);
        
        String uniquePrintData = JSON.serialize(pWrapper); 
        
        pWrapper = (PrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, PrintDataUtilityWrapper.class);
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        
        Test.startTest();
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		Test.stopTest();
        
        List<SBQQ__QuoteLine__c> quoteLine = [Select Id From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: quote.Id];
        //System.assertEquals(1, quoteLine.size());
    }
    
    //Opportunity update
    static testMethod void  test_createUtilityRecords8()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];

        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        opp.Contract_Strategy_Outcome__c = '1 Year';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Opportunity_Products__c = 'ESAM';
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
                            
        SBQQ__QuoteLine__c quoteLineParent = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineParent.SBQQ__Product__c = products[0].Id;
        quoteLineParent.Top_Parent_Product__c = products[0].Parent_Product__c;
        quoteLineParent.SBQQ__PricebookEntryId__c = products[0].PricebookEntries[0].Id;
        insert quoteLineParent;
        System.assert(quoteLineParent.Id != null);
        
        List<SBQQ__ProductOption__c> productOptions = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: products[1].Id];
        System.assert(productOptions != null);
        System.assert(productOptions.size() > 0);
        
        List<SBQQ__ProductFeature__c> features = [Select Id, Name From SBQQ__ProductFeature__c Where SBQQ__ConfiguredSKU__c =:products[1].Id];
        System.assert(features != null);
        System.assert(features.size() > 0);
        
        SBQQ__QuoteLine__c quoteLineChild = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineChild.SBQQ__Product__c = products[1].Id;
        quoteLineChild.Top_Parent_Product__c = products[1].Parent_Product__c;
        quoteLineChild.SBQQ__ProductOption__c = productOptions[0].Id;
        quoteLineChild.SBQQ__PricebookEntryId__c = products[1].PricebookEntries[0].Id;
        quoteLineChild.SBQQ__DynamicOptionId__c = features[0].Id;
        quoteLineChild.SBQQ__RequiredBy__c = quoteLineParent.Id;
        insert quoteLineChild;
        
        System.assert(quoteLineChild.Id != null);
        
         Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 9;// index for update opportunity
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Parent_1', quoteLineParent.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Child_1', quoteLineChild.Id);
        
        Test.startTest();
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		Test.stopTest();
        
        Opportunity opportunity = [Select Id, StageName, Contract_Signature_Date__c, SBQQ__Contracted__c From Opportunity Where Id =:opp.Id];
        System.assert(opportunity != null);
        System.assert(opportunity.Contract_Signature_Date__c != null);
        System.assertEquals('Contract Received - Send to Finance', opportunity.StageName);
		System.assertEquals(true, opportunity.SBQQ__Contracted__c);
    }
    
    static testMethod void test_createUtilityRecords9()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(false);
        account.recordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        insert account;
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];

        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        opp.Contract_Strategy_Outcome__c = '1 Year';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Opportunity_Products__c = 'ESAM';
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
                            
        SBQQ__QuoteLine__c quoteLineParent = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineParent.SBQQ__Product__c = products[0].Id;
        quoteLineParent.Top_Parent_Product__c = products[0].Parent_Product__c;
        quoteLineParent.SBQQ__PricebookEntryId__c = products[0].PricebookEntries[0].Id;
        insert quoteLineParent;
        System.assert(quoteLineParent.Id != null);
        
        List<SBQQ__ProductOption__c> productOptions = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: products[1].Id];
        System.assert(productOptions != null);
        System.assert(productOptions.size() > 0);
        
        List<SBQQ__ProductFeature__c> features = [Select Id, Name From SBQQ__ProductFeature__c Where SBQQ__ConfiguredSKU__c =:products[1].Id];
        System.assert(features != null);
        System.assert(features.size() > 0);
        
        SBQQ__QuoteLine__c quoteLineChild = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineChild.SBQQ__Product__c = products[1].Id;
        quoteLineChild.Top_Parent_Product__c = products[1].Parent_Product__c;
        quoteLineChild.SBQQ__ProductOption__c = productOptions[0].Id;
        quoteLineChild.SBQQ__PricebookEntryId__c = products[1].PricebookEntries[0].Id;
        quoteLineChild.SBQQ__DynamicOptionId__c = features[0].Id;
        quoteLineChild.SBQQ__RequiredBy__c = quoteLineParent.Id;
        insert quoteLineChild;
        
        System.assert(quoteLineChild.Id != null);
        
        // Create contract
        List<Contract> contracts = new List<Contract>(); 
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = account.Id,
                                   SBQQ__Quote__c = quote.Id, SBQQ__Opportunity__c = opp.Id));
        insert contracts;
        System.assert(contracts[0].Id != null);
        
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        psaProject.pse__Region__c = globalRegion.Id;
        psaProject.CurrencyIsoCode = 'USD';
        psaProject.Capitalizable__c = true;
        psaProject.pse__Is_Active__c = true;
        psaProject.pse__Allow_Timecards_Without_Assignment__c = true;
        psaProject.pse__Billing_Type__c = 'Non-Billable';
        psaProject.pse__Closed_for_Time_Entry__c = false;
        psaProject.Milestone_Revenue_Only__c = true;
        insert psaProject;
        System.assert(psaProject.Id != null);
        
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        Project__c project = new Project__c(Name = 'Test' , Institution__c = account.Id, PSA_Project__c = psaProject.Id,RecordTypeId = projRecordTypeId, Contract2__c = contracts[0].Id);
        insert project;
        System.assert(project.Id != null);

        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = account.Id, Project_Manager__c = UserInfo.getUserId()));
        insert esc;
        System.assert(esc[0].Id != null);
        
        
        Test.startTest();
        // Insert job ticket
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Project_Manager__c = UserInfo.getUserId(), Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345' ));
        insert jobTickets;
        System.assert(jobTickets[0].Id != null);
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 10;// index for Job_Ticket__c
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Parent_1', quoteLineParent.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Child_1', quoteLineChild.Id);
        
        //Test.startTest();
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		Test.stopTest();
        
        jobTickets = [Select Id, Name, Postage_Class__c, Descriptive_Name__c From Job_Ticket__c];
        System.assertEquals(1, jobTickets.size());
        System.assertEquals('Non-Profit (200 Piece Minimum)', jobTickets[0].Postage_Class__c);
        System.assertEquals('Digital', jobTickets[0].Descriptive_Name__c);
    }
    
    static testMethod void test_createUtilityRecords10()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];

        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        opp.Contract_Strategy_Outcome__c = '1 Year';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Opportunity_Products__c = 'ESAM';
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
                            
        SBQQ__QuoteLine__c quoteLineParent = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineParent.SBQQ__Product__c = products[0].Id;
        quoteLineParent.Top_Parent_Product__c = products[0].Parent_Product__c;
        quoteLineParent.SBQQ__PricebookEntryId__c = products[0].PricebookEntries[0].Id;
        insert quoteLineParent;
        System.assert(quoteLineParent.Id != null);
        
        List<SBQQ__ProductOption__c> productOptions = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: products[1].Id];
        System.assert(productOptions != null);
        System.assert(productOptions.size() > 0);
        
        List<SBQQ__ProductFeature__c> features = [Select Id, Name From SBQQ__ProductFeature__c Where SBQQ__ConfiguredSKU__c =:products[1].Id];
        System.assert(features != null);
        System.assert(features.size() > 0);
        
        SBQQ__QuoteLine__c quoteLineChild = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineChild.SBQQ__Product__c = products[1].Id;
        quoteLineChild.Top_Parent_Product__c = products[1].Parent_Product__c;
        quoteLineChild.SBQQ__ProductOption__c = productOptions[0].Id;
        quoteLineChild.SBQQ__PricebookEntryId__c = products[1].PricebookEntries[0].Id;
        quoteLineChild.SBQQ__DynamicOptionId__c = features[0].Id;
        quoteLineChild.SBQQ__RequiredBy__c = quoteLineParent.Id;
        insert quoteLineChild;
        
        System.assert(quoteLineChild.Id != null);
        
        // Create contract
        List<Contract> contracts = new List<Contract>(); 
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = account.Id,
                                   SBQQ__Quote__c = quote.Id, SBQQ__Opportunity__c = opp.Id));
        insert contracts;
        System.assert(contracts[0].Id != null);
        
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        psaProject.pse__Region__c = globalRegion.Id;
        psaProject.CurrencyIsoCode = 'USD';
        psaProject.Capitalizable__c = true;
        psaProject.pse__Is_Active__c = true;
        psaProject.pse__Allow_Timecards_Without_Assignment__c = true;
        psaProject.pse__Billing_Type__c = 'Non-Billable';
        psaProject.pse__Closed_for_Time_Entry__c = false;
        psaProject.Milestone_Revenue_Only__c = true;
        insert psaProject;
        System.assert(psaProject.Id != null);
        
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        Project__c project = new Project__c(Name = 'Test' , Institution__c = account.Id, PSA_Project__c = psaProject.Id,RecordTypeId = projRecordTypeId, Contract2__c = contracts[0].Id);
        insert project;
        System.assert(project.Id != null);

        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = account.Id, Project_Manager__c = UserInfo.getUserId()));
        insert esc;
        System.assert(esc[0].Id != null);
        
        
        Test.startTest();
        
        // Insert job ticket
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Project_Manager__c = UserInfo.getUserId(), Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345' ));
        insert jobTickets;
        System.assert(jobTickets[0].Id != null);
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 11;//  index for Job_Ticket_MtM__c
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Parent_1', quoteLineParent.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Child_1', quoteLineChild.Id);
        mapUniqueKeyWithRecordId.put('Job_Ticket_1', jobTickets[0].Id);
        
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		Test.stopTest();
        
        List<Job_Ticket_MtM__c> jobTicketMtm = [Select Id, Name, Status__c From Job_Ticket_MtM__c Where Job_Ticket__c =: jobTickets[0].Id];
        System.assertEquals(2, jobTicketMtm.size());
        System.assertEquals('Draft', jobTicketMtm[0].Status__c);
        System.assertEquals('Draft', jobTicketMtm[1].Status__c);
        
        Set<Id> jobTicketMtmIds = new Set<Id>();
        for(Job_Ticket_MtM__c jtmtm : jobTicketMtm)
        {
            jobTicketMtmIds.add(jtmtm.Id);
        }
        
        List<Associated_Features__c> af = [Select Id From Associated_Features__c  Where Job_Ticket_MtM__c IN: jobTicketMtmIds];
        System.assertEquals(2, af.size());   
    }
    
    static testMethod void test_createUtilityRecords11(){
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(false);
        account.recordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        insert account;
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];

        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        opp.Contract_Strategy_Outcome__c = '1 Year';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Opportunity_Products__c = 'ESAM';
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
                            
        SBQQ__QuoteLine__c quoteLineParent = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineParent.SBQQ__Product__c = products[0].Id;
        quoteLineParent.Top_Parent_Product__c = products[0].Parent_Product__c;
        quoteLineParent.SBQQ__PricebookEntryId__c = products[0].PricebookEntries[0].Id;
        insert quoteLineParent;
        System.assert(quoteLineParent.Id != null);
        
        List<SBQQ__ProductOption__c> productOptions = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: products[1].Id];
        System.assert(productOptions != null);
        System.assert(productOptions.size() > 0);
        
        List<SBQQ__ProductFeature__c> features = [Select Id, Name From SBQQ__ProductFeature__c Where SBQQ__ConfiguredSKU__c =:products[1].Id];
        System.assert(features != null);
        System.assert(features.size() > 0);
        
        SBQQ__QuoteLine__c quoteLineChild = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineChild.SBQQ__Product__c = products[1].Id;
        quoteLineChild.Top_Parent_Product__c = products[1].Parent_Product__c;
        quoteLineChild.SBQQ__ProductOption__c = productOptions[0].Id;
        quoteLineChild.SBQQ__PricebookEntryId__c = products[1].PricebookEntries[0].Id;
        quoteLineChild.SBQQ__DynamicOptionId__c = features[0].Id;
        quoteLineChild.SBQQ__RequiredBy__c = quoteLineParent.Id;
        insert quoteLineChild;
        
        System.assert(quoteLineChild.Id != null);
        
        // Create contract
        List<Contract> contracts = new List<Contract>(); 
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = account.Id,
                                   SBQQ__Quote__c = quote.Id, SBQQ__Opportunity__c = opp.Id));
        insert contracts;
        System.assert(contracts[0].Id != null);
        
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        psaProject.pse__Region__c = globalRegion.Id;
        psaProject.CurrencyIsoCode = 'USD';
        psaProject.Capitalizable__c = true;
        psaProject.pse__Is_Active__c = true;
        psaProject.pse__Allow_Timecards_Without_Assignment__c = true;
        psaProject.pse__Billing_Type__c = 'Non-Billable';
        psaProject.pse__Closed_for_Time_Entry__c = false;
        psaProject.Milestone_Revenue_Only__c = true;
        insert psaProject;
        System.assert(psaProject.Id != null);
        
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        Project__c project = new Project__c(Name = 'Test' , Institution__c = account.Id, PSA_Project__c = psaProject.Id,RecordTypeId = projRecordTypeId, Contract2__c = contracts[0].Id);
        insert project;
        System.assert(project.Id != null);

        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = account.Id, Project_Manager__c = UserInfo.getUserId()));
        insert esc;
        System.assert(esc[0].Id != null);
        
        
        Test.startTest();
        // Insert job ticket
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Project_Manager__c = UserInfo.getUserId(), Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345' ));
        insert jobTickets;
        System.assert(jobTickets[0].Id != null);
        
        
        // create productionTracking record.
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  account.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 1,
                                                  Art_File_Name__c = 'artFile1.zip', RecordTypeId=Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId()));
		insert pTrackings;
        System.assert(pTrackings[0].Id != null);
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 12;// index for Production_Tracking__c
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Parent_1', quoteLineParent.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Child_1', quoteLineChild.Id);
        mapUniqueKeyWithRecordId.put('Job_Ticket_1', jobTickets[0].Id);
        mapUniqueKeyWithRecordId.put('productionTracking_1', pTrackings[0].Id);
        
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		Test.stopTest();
        
        pTrackings = [Select Id, New_Art__c, Print_Quantity_Planned__c, Proof_Generation__c From Production_Tracking__c Where Id =:pTrackings[0].Id];
        System.assertEquals(1, pTrackings.size());
        System.assertEquals(true, pTrackings[0].New_Art__c);
    }
    
    static testMethod void test_createUtilityRecords12()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(false);
        account.recordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        insert account;
        System.assert(account.Id != null);
        
        Contact contact = TestUtilities.CreateNewContact(account, true);
        System.assert(contact.Id != null);
        
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];

        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id, false);
        opp.Main_Contact__c = contact.Id;
        opp.Contract_Strategy_Outcome__c = '1 Year';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Opportunity_Products__c = 'ESAM';
        insert opp;
        System.assert(opp.Id != null);
        
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = contact.Id;
        insert quote;
        System.assert(quote.Id != null);
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        List<Product2> products = [Select Id, Name, ProductCode, Parent_Product__c, (Select ID from PricebookEntries limit 1) From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
                            
        SBQQ__QuoteLine__c quoteLineParent = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineParent.SBQQ__Product__c = products[0].Id;
        quoteLineParent.Top_Parent_Product__c = products[0].Parent_Product__c;
        quoteLineParent.SBQQ__PricebookEntryId__c = products[0].PricebookEntries[0].Id;
        insert quoteLineParent;
        System.assert(quoteLineParent.Id != null);
        
        List<SBQQ__ProductOption__c> productOptions = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: products[1].Id];
        System.assert(productOptions != null);
        System.assert(productOptions.size() > 0);
        
        List<SBQQ__ProductFeature__c> features = [Select Id, Name From SBQQ__ProductFeature__c Where SBQQ__ConfiguredSKU__c =:products[1].Id];
        System.assert(features != null);
        System.assert(features.size() > 0);
        
        SBQQ__QuoteLine__c quoteLineChild = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLineChild.SBQQ__Product__c = products[1].Id;
        quoteLineChild.Top_Parent_Product__c = products[1].Parent_Product__c;
        quoteLineChild.SBQQ__ProductOption__c = productOptions[0].Id;
        quoteLineChild.SBQQ__PricebookEntryId__c = products[1].PricebookEntries[0].Id;
        quoteLineChild.SBQQ__DynamicOptionId__c = features[0].Id;
        quoteLineChild.SBQQ__RequiredBy__c = quoteLineParent.Id;
        insert quoteLineChild;
        
        System.assert(quoteLineChild.Id != null);
        
        // Create contract
        List<Contract> contracts = new List<Contract>(); 
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = account.Id,
                                   SBQQ__Quote__c = quote.Id, SBQQ__Opportunity__c = opp.Id));
        insert contracts;
        System.assert(contracts[0].Id != null);
        
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        pse__Proj__c psaProject = new pse__Proj__c();
        psaProject.name = 'Test_PSA_Project';
        psaProject.pse__Region__c = globalRegion.Id;
        psaProject.CurrencyIsoCode = 'USD';
        psaProject.Capitalizable__c = true;
        psaProject.pse__Is_Active__c = true;
        psaProject.pse__Allow_Timecards_Without_Assignment__c = true;
        psaProject.pse__Billing_Type__c = 'Non-Billable';
        psaProject.pse__Closed_for_Time_Entry__c = false;
        psaProject.Milestone_Revenue_Only__c = true;
        insert psaProject;
        System.assert(psaProject.Id != null);
        
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        Project__c project = new Project__c(Name = 'Test' , Institution__c = account.Id, PSA_Project__c = psaProject.Id,RecordTypeId = projRecordTypeId, Contract2__c = contracts[0].Id);
        insert project;
        System.assert(project.Id != null);

        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = account.Id, Project_Manager__c = UserInfo.getUserId()));
        insert esc;
        System.assert(esc[0].Id != null);
        
        
        Test.startTest();
        // Insert job ticket
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Project_Manager__c = UserInfo.getUserId(), Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345' ));
        insert jobTickets;
        System.assert(jobTickets[0].Id != null);
        
        
        // create productionTracking record.
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  account.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 1,
                                                  Art_File_Name__c = 'artFile1.zip', RecordTypeId=Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId()));
		insert pTrackings;
        System.assert(pTrackings[0].Id != null);
        
        Map<Integer, Id> mapCounterWithRecordId = new Map<Integer, Id>();
        Integer counter = 1;
        Set<Id> quoteLineRecordIds = new Set<Id>();
        Map<String, ID> mapUniqueKeyWithRecordId = new Map<String, ID>();
        Integer currentIndex = 13;// index for Inventory__c
        String uniquePrintData = JSON.serialize(getPrintWrapperData(account));
        
        // Query all "OE/BRE Test Data" the metadata record and add record with respect to index in map.
        for(Create_Dev_Sandbox_Record__mdt createDevData : [SELECT ID, MasterLabel, DeveloperName, Child_Record__c, Object_API_Name__c, Parent_Field_API_Name__c, 
                                                            Record_Level__c, Order__c, Parent_Object_API_Name__c, Records__c
                                                            FROM Create_Dev_Sandbox_Record__mdt
                                                            WHERE Active__c =: true AND Process_Belongs_To__c = 'OE/BRE Test Data'
                                                            ORDER By Record_Level__c ASC, Order__c ASC])
        {
            mapCounterWithRecordId.put(counter, createDevData.Id); 
			counter++;
            if(createDevData.DeveloperName == 'Proposal_Line_Grand_Child' || createDevData.DeveloperName == 'Proposal_Line_Child')
            	quoteLineRecordIds.add(createDevData.Id);
        }
        
        // Fill map mapUniqueKeyWithRecordId
        mapUniqueKeyWithRecordId.put('Account_1', account.Id);
        mapUniqueKeyWithRecordId.put('Contact_1', contact.Id);
        mapUniqueKeyWithRecordId.put('Opportunity_1', opp.Id);
        mapUniqueKeyWithRecordId.put('Proposal_1', quote.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Parent_1', quoteLineParent.Id);
        mapUniqueKeyWithRecordId.put('Proposal_Line_Child_1', quoteLineChild.Id);
        mapUniqueKeyWithRecordId.put('Job_Ticket_1', jobTickets[0].Id);
        mapUniqueKeyWithRecordId.put('productionTracking_1', pTrackings[0].Id);
        
        Sched_CreateDevSBRecord.createUtilityRecords(mapCounterWithRecordId, currentIndex, mapUniqueKeyWithRecordId, quoteLineRecordIds, uniquePrintData);
		
        Test.stopTest();
    }
    
    
    static PrintDataUtilityWrapper getPrintWrapperData(Account account){
        PrintDataUtilityWrapper pWrapper = new PrintDataUtilityWrapper();
        //Inventory Transaction Fields
        pWrapper.IT_Print_Vendor = account.Id;
        pWrapper.IT_Mail_Vendor = account.Id;
        
        //Job Ticket Fields
        pWrapper.JT_Drop_Type = 'Pre Planned';
        pWrapper.JT_Vendor_Type = 'Digital';
        pWrapper.JT_Mail_Vendor = account.Id;
        pWrapper.JT_No_Of_Drop  = 2;
        pWrapper.JT_Project_ID  = '15254';
                
        //List of user emails for send final mail
        pWrapper.emailList = new List<String>{'test.junkeab@eab.com'};
        return (pWrapper);
        
    }
}