/*
Purpose         :   Apex Class where we will create all the data records that's going to be utilized in other test classes for data setup.
Created By      :   Abhinav Sharma
Created Date    :   08/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/11/2021
*/
@isTest(seeAllData=false)
public without sharing class dynlistTestDataFactory 
{
    //Method to create the test data for Account object
    @IsTest(seeAllData=false)
    public static Account createAccountTestData()
    {
        //Account
        Account account = (Account)dynlistSmartFactory.createSObject(dynlistConstants.OBJECT_NAME_ACCOUNT);
        Util.BypassAllTriggers = true;
        insert account;
        Util.BypassAllTriggers = false;
        System.assert(account.Id != null);
        return account;
    }
    
    //Method to create the test data for Account object
    @IsTest(seeAllData=false)
    public static List<Account> createListOfAccountsTestData()
    {
        //Account
        List<Account> accounts= (List<Account>)dynlistSmartFactory.createSObjectList(dynlistConstants.OBJECT_NAME_ACCOUNT, false, 5);
        Util.BypassAllTriggers = true;
        insert accounts;
        Util.BypassAllTriggers = false;
        System.assertEquals(5,accounts.size());
        return accounts;
    }
    
    //Method to create the test data for Case object
    @IsTest(seeAllData=false)
    public static List<Case> createListOfCasesTestData()
    {
        //Case
        List<Case> cases = (List<Case>)dynlistSmartFactory.createSObjectList(dynlistConstants.OBJECT_NAME_CASE, false, 5);
        Util.BypassAllTriggers = true;
	insert cases;
	Util.BypassAllTriggers = false;
        System.assertEquals(5,cases.size());
        return cases;
    }
    
    //Method to create the test data for contact object
    @IsTest(seeAllData=false)
    public static Contact createContactTestData()
    {
        Account acc = dynlistTestDataFactory.createAccountTestData();
        Contact contact = (Contact)dynlistSmartFactory.createSObject(dynlistConstants.OBJECT_NAME_CONTACT, false);
        contact.AccountId = acc.Id;
        contact.Email = 'testing' + String.valueOf(Math.random()) + '@test.com';
        contact.Title = 'Test Contact';
        contact.Phone = '1234567890';
        
        contact.Contact_Status__c = 'Active';
        contact.Employee_User_Record__c = Userinfo.getUserId();
        
        Util.BypassAllTriggers = true;
        insert contact;
        Util.BypassAllTriggers = false;
        System.assert(contact.Id != null);
        return contact;
    }
    
    //Method to create the test data for Opportunity object
    @IsTest(seeAllData=false)
    public static Opportunity createOpportunityTestData()
    {
        //Contact
        Contact contact = dynlistTestDataFactory.createContactTestData();
        Opportunity opportunity = (Opportunity)dynlistSmartFactory.createSObject(dynlistConstants.OBJECT_NAME_OPPORTUNITY, false);
        opportunity.AccountId = contact.AccountId;
        opportunity.StageName = '0-Exploring';
        opportunity.CloseDate = System.today().addMonths(1);
        opportunity = dynlistTestDataFactory.populateOpportunityRequiredFields(opportunity, contact);
        
        Util.BypassAllTriggers = true;
        insert opportunity;
        Util.BypassAllTriggers = false;
        System.assert(opportunity.Id != null);
        return opportunity;
    }
    
    //Method to create the test data for Opportunity object
    @IsTest(seeAllData=false)
    public static List<Opportunity> createListOfOpportunitiesTestData()
    {
        //Opportunity
        List<Opportunity> opportunities= (List<Opportunity>)dynlistSmartFactory.createSObjectList(dynlistConstants.OBJECT_NAME_OPPORTUNITY, false, 5);
        
        //Contact
        Contact contact = dynlistTestDataFactory.createContactTestData();
        
        //loop over the opportunities records
        for(Integer i=0; i<opportunities.size(); i++){
            opportunities[i].AccountId = contact.AccountId;
            opportunities[i].StageName = '0-Exploring';
            opportunities[i].CloseDate = System.today().addMonths(1);
            opportunities[i] = dynlistTestDataFactory.populateOpportunityRequiredFields(opportunities[i], contact);
        }
        
        Util.BypassAllTriggers =  true;
        //insert opportunities
        insert opportunities;
        Util.BypassAllTriggers =  false;
        //asserts
        System.assertEquals(5,opportunities.size());
        
        return opportunities;
    }
    
    private static Opportunity populateOpportunityRequiredFields(Opportunity opp, Contact con) 
    {
        if(opp != null) 
        {
            if(con != null)
            {
            	opp.Main_Contact__c = con.Id;        
            }
        }
        return opp;
    }
    
    //Method to create the test data for Application Setting object
    @IsTest(seeAllData=false)
    public static Dynlist_Application_Setting__c createApplicationSettingTestData()
    {
        //Opportunity
        Dynlist_Application_Setting__c applicationSetting = (Dynlist_Application_Setting__c)dynlistSmartFactory.createSObject(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, false);
        applicationSetting.Name = System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME;
        applicationSetting.Display__c = dynlistConstants.CHAR_HIDDEN;
        applicationSetting.Text_area_value__c = '{"records":[' + 
            '{"TargetEntityDefinition":{"FullName":"Account"},' + 
            '"SourceFieldDefinition":{"FullName":"' + System.Label.DYNLIST_OPP_FILTER_FIELD_NAME + '"},'+
            '"Metadata":{"isOptional":false,"infoMessage":null,"filterItems":[' +
            '{"valueField":null,"value":"Burlington","operation":"contains","field":"Account.Name"},' +
            '{"valueField":null,"value":"XYZ","operation":"notEqual","field":"Account.CreatedBy.FirstName"}],'+
            '"errorMessage":null,"description":null,"booleanFilter":" {A} AND {B} ","active":true},'+
            '"DeveloperName":null}' +
            ']}';
        applicationSetting.Text_area_value_2__c = '{"records":[' + 
            '{"TargetEntityDefinition":{"FullName":"Account"},' + 
            '"SourceFieldDefinition":{"FullName":"' + System.Label.DYNLIST_OPP_FILTER_FIELD_NAME + '"},'+
            '"Metadata":{"isOptional":false,"infoMessage":null,"filterItems":[' +
            '{"valueField":null,"value":"Burlington","operation":"contains","field":"Account.Name"},' +
            '{"valueField":null,"value":"XYZ","operation":"notEqual","field":"Account.CreatedBy.FirstName"}],'+
            '"errorMessage":null,"description":null,"booleanFilter":" {A} AND {B} ","active":true},'+
            '"DeveloperName":null}' +
            ']}';
        applicationSetting.Text_area_value_3__c = '{"records":[' + 
            '{"TargetEntityDefinition":{"FullName":"Account"},' + 
            '"SourceFieldDefinition":{"FullName":"' + System.Label.DYNLIST_OPP_FILTER_FIELD_NAME + '"},'+
            '"Metadata":{"isOptional":false,"infoMessage":null,"filterItems":[' +
            '{"valueField":null,"value":"Burlington","operation":"contains","field":"Account.Name"},' +
            '{"valueField":null,"value":"XYZ","operation":"notEqual","field":"Account.CreatedBy.FirstName"}],'+
            '"errorMessage":null,"description":null,"booleanFilter":" {A} AND {B} ","active":true},'+
            '"DeveloperName":null}' +
            ']}';
        
        //Inserting applicationSetting
        Util.BypassAllTriggers =  true;
        Insert applicationSetting;
        Util.BypassAllTriggers =  false;
        //asserts
        System.assert(applicationSetting.Id != null);
        
        return applicationSetting;
    }
    
    //Method to create the test data for Application Setting object
    @IsTest(seeAllData=false)
    public static Dynlist_Application_Setting__c createApplicationSettingTestDataV2()
    {
        //Opportunity
        Dynlist_Application_Setting__c applicationSetting = (Dynlist_Application_Setting__c)dynlistSmartFactory.createSObject(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, false);
        applicationSetting.Name = 'Lookup_Filter_Json';
        applicationSetting.Display__c = 'Hidden';
        applicationSetting.Text_area_value__c = '{"records":[' + 
            '{"TargetEntityDefinition":{"FullName":"Account"},' + 
            '"SourceFieldDefinition":{"FullName":"' + System.Label.DYNLIST_APPLICATION_SETTINGS_ACCOUNT_FIELD_NAME + '"},'+
            '"Metadata":{"isOptional":false,"infoMessage":null,"filterItems":[' +
            '{"valueField":null,"value":"System Administrator","operation":"equals","field":"$Profile.Name"},' +
            '{"valueField":null,"value":"True","operation":"equals","field":"$User.IsActive"}],'+
            '"errorMessage":null,"description":null,"booleanFilter":" {A} AND {B} ","active":true},'+
            '"DeveloperName":null}' +
            ']}';
        
        //Inserting applicationSetting
        Util.BypassAllTriggers = true;
        Insert applicationSetting;
        Util.BypassAllTriggers = false;
        //asserts
        System.assert(applicationSetting.Id != null);
        
        return applicationSetting;
    }
    
    //Method to create the test data for Application Setting object
    @IsTest(seeAllData=false)
    public static List<Dynlist_Application_Setting__c> createListOfApplicationSettingTestData()
    {
        //Application Setting records
        List<Dynlist_Application_Setting__c> applicationSettings = (List<Dynlist_Application_Setting__c>)dynlistSmartFactory.createSObjectList(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, false, 5);
        for(Integer i=0; i<applicationSettings.size();i++){
            applicationSettings[i].Name = 'Lookup_Filter_Json';
            applicationSettings[i].Display__c = 'Hidden';
            applicationSettings[i].Text_area_value__c = '{"records":[' + 
                '{"TargetEntityDefinition":{"FullName":"Account"},' + 
                '"SourceFieldDefinition":{"FullName":"' + System.Label.DYNLIST_OPP_FILTER_FIELD_NAME + '"},'+
                '"Metadata":{"isOptional":false,"infoMessage":null,"filterItems":[' +
                '{"valueField":null,"value":"Burlington","operation":"contains","field":"Account.Name"},' +
                '{"valueField":null,"value":"XYZ","operation":"notEqual","field":"Account.CreatedBy.FirstName"}],'+
                '"errorMessage":null,"description":null,"booleanFilter":" {A} AND {B} ","active":true},'+
                '"DeveloperName":null}' +
                ']}';
        }
        
        Util.BypassAllTriggers = true;
        //Inserting applicationSetting
        Insert applicationSettings;
        Util.BypassAllTriggers = false;
        //asserts
        System.assert(applicationSettings != null);
        
        return applicationSettings;
    }
    
    //Method to create the test data for Opportunity object
    @IsTest(seeAllData=false)
    public static Contract createContractTestData()
    {
        //Contract
        Contract contract = (Contract)dynlistSmartFactory.createSObject(dynlistConstants.OBJECT_NAME_CONTRACT);
        
        //Account 
        Account account = dynlistTestDataFactory.createAccountTestData();
        
        contract.AccountId = account.Id;
        contract.status = 'Draft';
        //insert Contract
        Util.BypassAllTriggers = true;
        insert contract;
        Util.BypassAllTriggers = false;
        //asserts
        System.assert(contract.Id!=null);
        
        return contract;
    }
    
    // Method to create the test data for User object.
    @IsTest(seeAllData=false)
    public static User createUserTestData(){
        
        // Query GuestLicenseUser profile.
        Profile profile = [Select Id From Profile Where Name =: System.Label.DYNLIST_CHATTER_FREE_USER_PROFILE_NAME];
        System.assert(profile.Id != null);
        
        // User
        User user = (User)dynlistSmartFactory.createSObject(dynlistConstants.CHAR_USER);
        user.Alias = 'tUser';
        user.Email = 'tUser@noreply.com';
        user.EmailEncodingKey = 'UTF-8';
        user.LastName = 'User';
        user.ProfileId = profile.Id;
        user.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
        user.TimeZoneSidKey = 'America/New_York';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        
	Util.BypassAllTriggers = true;
        // Insert user.
        insert user;
	Util.BypassAllTriggers = false;
        
        // asserts
        System.assert(user.Id != null);
        
        return user;
    }
}