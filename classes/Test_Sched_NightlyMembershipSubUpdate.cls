/**
 *   Purpose         :   Test class for Sched_NightlyMembershipSubUpdate
 *            
 *   Create By       :   Abhishek Mishra
 * 
 *   Created Date    :   07/07/2021
 *
 *   Revision Log    :   V_1.0 - Created - Abhishek Mishra - CR-20211005-15489 
 *
 **/  
@isTest(seeAllData = false)
public class Test_Sched_NightlyMembershipSubUpdate 
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
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        products.add(new Product2(Name = 'Travel Fee', IsActive = true, ProductCode = 'TravelFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Travel Fee', Program_Name_Member_Facing__c = 'Travel Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        products.add(new Product2(Name = 'Offer', IsActive = true, ProductCode = 'Offer', SBQQ__Component__c = true,Offer__c = true,
                                  Product_Category__c = 'Offer', Program_Name_Member_Facing__c = 'Offer',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Trevel Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Offer', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[3].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        insert productOptions;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        accounts.add(TestUtilities.CreateNewAccount(false));
        accounts.add(TestUtilities.CreateNewAccount(false));
        accounts[0].RecordTypeId = accountUSCorporateRecordType;
        accounts[1].RecordTypeId = accountUSCorporateRecordType;
        accounts[0].Status__c = 'Active';
        accounts[1].Status__c = 'Active';
        //Insert
        insert accounts;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(TestUtilities.CreateNewMembership(accounts[0].Id, programs[0].Id, false));
        memberships.add(TestUtilities.CreateNewMembership(accounts[1].Id, programs[0].Id, false));
        insert memberships;
        
        //SOQL over the opportunity Record Type0
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = TestUtilities.CreateNewContact(accounts[0], false);
        contact.Contact_Status__c = 'Active';
        contact.recordTypeId = conRType[0].Id;
        insert contact;
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        //Insert IBS
        insert invoices;
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        contracts.add(TestUtilities.CreateNewContract(accounts[0].Id, contact.Id, programs[0].Id, false)); 
        contracts.add(TestUtilities.CreateNewContract(accounts[0].Id,contact.Id,programs[0].Id, false));
        
        contracts[0].Invoicing_Arrangement__c = 'Special';
        contracts[0].Invoice_Billing_Schedule__c = invoices[0].Id;
        
        contracts[1].Invoicing_Arrangement__c = 'Special';
        contracts[1].Invoice_Billing_Schedule__c = invoices[0].Id;
        insert contracts;
        
        //Creating new Custom setting Data 
        List<Sync_Field__c> syncFields = new List<Sync_Field__c>();
        syncFields.add(new Sync_Field__c(Name = 'Test', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Program', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        syncFields.add(new Sync_Field__c(Name = 'Test1', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Component', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        insert syncFields;
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void testSched_NightlyMembershipSubUpdate()
    {
        Test.startTest();
        
        //Schedule the job
        Sched_NightlyMembershipSubUpdate sch = new Sched_NightlyMembershipSubUpdate();
        System.Schedule('Test Sched_NightlyMembershipSubUpdate','0 0 22 * * ? *', new Sched_NightlyMembershipSubUpdate());
        
        Test.stopTest();
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        
        //Asserts
        System.assertEquals('Sched_NightlyMembershipSubUpdate', asyncApexJob[0].ApexClass.Name);
        System.assertEquals('Batch_NightlyMembershipSubUpdate', jobsApexBatch[0].ApexClass.Name);
    }
}