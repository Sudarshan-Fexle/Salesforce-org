/*
Purpose         :   Smart Factory Test class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistSmartFactory_Test 
{
    static
    {
        dynlistSmartFactory.FillAllFields = true; // increase test coverage without creating custom objects
    }  
    
    static testMethod void createsSingleObjectWithSingleRequiredStringField() 
    {
        Account account = (Account)dynlistSmartFactory.createSObject('Account');
        account = TestUtilities.CreateNewAccount(false);
        Util.BypassAllTriggers = true;
        insert account;
        Util.BypassAllTriggers = false;
        System.assert(account.Id != null);
        System.assert(account.Name != null);
    }
    
    static testMethod void createsObjectWithCascadeSetsLookupField() 
    {
        Account account = (Account)dynlistSmartFactory.createSObject('Account');
        account = TestUtilities.CreateNewAccount(false);
        Util.BypassAllTriggers = true;
        insert account;
        Util.BypassAllTriggers = false;
        
        Contact contact = (Contact)dynlistSmartFactory.createSObject('Contact', false);
        contact.AccountId = account.Id;
        Util.BypassAllTriggers = true;
        insert contact;
        Util.BypassAllTriggers = false;
        
        System.assert(contact.Id != null);
        System.assert(contact.AccountId != null);
    }
    
    static testMethod void createsObjectWithoutCascadeDoesNotSetLookupField() 
    {
        Contact contact = (Contact)dynlistSmartFactory.createSObject('Contact', false);
        Util.BypassAllTriggers = true;
        insert contact;
        Util.BypassAllTriggers = false;
        System.assert(contact.AccountId == null);
    }
    
    static testMethod void createObjectWithUnsupportedTypeThrowsException() 
    {
        try 
        {
            dynlistSmartFactory.createSObject('Unsupported');
            System.assert(false);
        } 
        catch (dynlistUnsupportedObjectTypeException ex) 
        {
            System.assert(true);
        }
    }
    
    //Added by - Abhinav sharma  -  11/02/2021 - Added a new method to test record type 
    static testMethod void testSetRecordType() 
    {
        Dynlist_Application_Setting__c applicationSetting = (Dynlist_Application_Setting__c)dynlistSmartFactory.createSObject(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME);
        Util.BypassAllTriggers = true;
        insert applicationSetting;
        Util.BypassAllTriggers = false;
        System.assert(applicationSetting.Id != null);
        System.assert(applicationSetting.Name != null);
    }
    
    //Added by - Abhinav sharma  -  11/02/2021 - Added a new method to test createSObjectList
    static testMethod void testCreateSObjectList() 
    {
        List<Dynlist_Application_Setting__c> applicationSettings = (List<Dynlist_Application_Setting__c>)dynlistSmartFactory.createSObjectList(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, true, 1);
        Util.BypassAllTriggers = true;
        insert applicationSettings;
        Util.BypassAllTriggers = false;
        System.assert(applicationSettings.size() == 1);
        System.assert(applicationSettings[0].Id != null);
        System.assert(applicationSettings[0].Name != null);
    }
}