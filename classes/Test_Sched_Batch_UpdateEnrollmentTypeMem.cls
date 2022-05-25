/**
 *  Description     :   This Apex Test class used to test the class "Sched_Batch_UpdateEnrollmentTypeMem" functionality.
 * 
 *  Created By      :  Dipesh Gupta 
 * 
 *  Created Date    :   01/27/2020
 * 
 *  Revision Logs   :   V_1.0 - Created (CR-20190718-13214) 
 *
 **/
@isTest(seeAllData=false)
public class Test_Sched_Batch_UpdateEnrollmentTypeMem {
    
    static testMethod void unitTest1()
    {
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Creating program record
        List<Program__c> programs = new List<Program__c> ();
        programs.add(TestUtilities.CreateNewProgram(true));

        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        products.add(new Product2(Name = 'New Names', Family = 'Enrollment Services', IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'New Names',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Program Costs', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Program Costs',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'New Name', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Program Costs', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[1].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productsOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productsOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Add records in list to insert
        productsOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productsOptions;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //Get Account
        List<Account> accounts = new List<Account>();
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accountUSCorporateRecordType;
        accounts.add(account);
        insert accounts;
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, programs[0].Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        
        insert membership;
        
        //Program Package "EAB" Record Type Id
		Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
		
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()-1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
		progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test3', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test4', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+2), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test5', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+3), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        insert progPacks;
        
        //Testing start here
        Test.startTest();
        	
        	//Cron Expression
            Datetime sysTime = System.now().addMinutes(1);
            String CRON_EXP = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            //Scheduling the scheduler 
            System.schedule('Job Started At ' + String.valueOf(Datetime.now()), CRON_EXP, new Sched_Batch_UpdateEnrollmentTypeMem());
        
        //Testing start here
        Test.stopTest();
        
    }
}