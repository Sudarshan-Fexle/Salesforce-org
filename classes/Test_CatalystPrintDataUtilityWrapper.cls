/**
*   Purpose         :   Test class for PrintDataUtilityWrapper
*            
*   Create By       :   Mahendar Swarnkar
* 
*   Created Date    :   05/10/2021
*   
*   Coverage        :   100%
*
**/
@isTest(seeAllData = false)
public class Test_CatalystPrintDataUtilityWrapper {
	@testSetup 
    static void dataSetup() {
        
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
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
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
     
    @isTest static void test_parseJSONstring()
    {
        List<Product2> products = [Select Id, Name, ProductCode From Product2 Where ProductCode != 'ESAMTopParent' ORDER BY ProductCode ASC];
        system.assertEquals(3, products.size());
        system.assertEquals('ESAM', products[0].ProductCode);
        system.assertEquals('ESAMESIP', products[1].ProductCode);
        system.assertEquals('ESAMPROGRAMCOST', products[2].ProductCode);
        
        List<Account> listAccount = [Select ID from Account];
        system.assertEquals(1, listAccount.size());
        
        Test.startTest();
        
        CatalystPrintDataUtilityWrapper pDUW = new CatalystPrintDataUtilityWrapper();
        //Inventory Transaction Fields
        pDUW.IT_Print_Vendor = listAccount[0].Id;
        pDUW.IT_Mail_Vendor = listAccount[0].Id;
        
        //Job Ticket Fields
        pDUW.JT_Drop_Type = 'Pre Planned';
        pDUW.JT_Vendor_Type = 'Digital';
        pDUW.JT_Mail_Vendor = listAccount[0].Id;
        pDUW.JT_No_Of_Drop  = 1;
        pDUW.JT_Project_ID  = '29694';
        
        pDUW.Parent_QL_Product = ''+products[0].Id;
        pDUW.Child_QL_Product = ''+products[1].Id;
        
        pDUW.emailList = new List<String>{'test@test.com', 'test1@test.com'};
        
        String uniquePrintData = JSON.serialize(pDUW);
        
        //PrintDataUtilityWrapper printWrapper =  (PrintDataUtilityWrapper)JSON.deserialize(uniquePrintData, PrintDataUtilityWrapper.class);
        
        Test.stopTest();
    }
}