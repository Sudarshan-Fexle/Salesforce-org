@isTest (seeAllData = false)
class Test_RestrictedMtM_Trigger
{
    /*
    Purpose:    Test Trigger RestrictedMtM_UpdateRestrictionStatus
    
    Create By:              
    
    Last Modified By:   Nathan Banas (SAP) - 1/24/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - Created code
                        v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
                        v1.2 - Ajit Surana - 03/12/2014 - CR-20140204-4450 - Test method modified - (testCaseContact4) 
                        v1.3 - Ajit Surana - 05/03/2014 - CR-20140418-5151 : All Test methods modified after API version upgradation
                        v1.4 - Abhinav Sharma - 10/21/2014 - CR-20140923-7430
                        v1.5 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
                        
    Code Coverage as of 1/20/2011: 100%
    */

    static testMethod void testCaseAccount() {
        
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];            
        
        Account acc = new Account();
        acc.Name = 'F3A2 Case Account 1 1';
        insert acc;
    
        Restrictions__c rest2 = new Restrictions__c();
        rest2.Category__c = 'Critical Background Information';
        rest2.Expiration_Date__c = system.today().addDays(10);
        insert rest2;
    
        Restricted_MtM__c restMtM2 = new Restricted_MtM__c();
        restMtM2.Restriction__c = rest2.Id;
        restMtM2.RecordTypeId = accRestrictionRecordType.ID;
        restMtM2.Account__c = acc.Id;
        restrictionMtMs.add(restMtM2);
        
        Restricted_MtM__c restMtM3 = new Restricted_MtM__c();
        restMtM3.Restriction__c = rest2.Id;
        restMtM3.RecordTypeId = accRestrictionRecordType.ID;
        restMtM3.Account__c = acc.Id;
        restrictionMtMs.add(restMtM3);
    
        //Test will start here
        Test.startTest();
        
        //Enabling triggers again
        util.BypassAllTriggers = false;
        
        //inserting MTM's
        insert restrictionMtMs;
        
        //Test will stop here
        Test.stopTest();

        Account acc1 = [select Id, Account_Restriction_Status__c from Account where Id =: acc.Id ];
    
        System.debug('Account : '+acc1);
        System.assertEquals('Critical Background Information',acc1.Account_Restriction_Status__c);
    
        acc1 = [select Id, Account_Restriction_Status__c, (select id from Restrictions_MtM__r) from Account where Id =: acc.Id ];
        system.assertequals(2, acc1.Restrictions_MtM__r.size());
    }
    
    static testMethod void testCaseContact1() {
        
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Account severe restriction, Contact severe restriction.
        Util.IsTesting = true;
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];            
        
        Account acc = new Account();
        acc.Name = 'Test Case Account 1';
        insert acc;
    
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Restricted: Permission Required';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;
    
        Contact cnt = new Contact();
        cnt.LastName = 'Test';
        cnt.AccountId = acc.Id;
		cnt.Email = 'Test'+Math.random()+'@eab.com';
		cnt.Title = 'Test';
		cnt.Phone = '614-555-8855';
        insert cnt;
    
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = accRestrictionRecordType.ID;
        restMtM.Account__c = acc.Id;
        restMtM.Run_Trigger__c = true;
        restrictionMtMs.add(restMtM);
        
        restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = conRestrictionRecordType.ID;
        restMtM.Contact__c = cnt.Id;
        restrictionMtMs.add(restMtM);
        
        //Test will start from here
        Test.startTest();
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
        
        //insert restrcited MTM's
        insert restrictionMtMs;
        
        //Test will stop here
        Test.stopTest();
    
        cnt = [select Contact_Restriction_Status__c from Contact where id = :cnt.id];
        system.assertEquals('Account - Restricted: Permission Required', cnt.Contact_Restriction_Status__c);
        
        restMtM = [select Run_Trigger__c from Restricted_MtM__c where id = :restMtM.id];
        system.assertEquals(false, restMtM.Run_Trigger__c);
    }
    
    static testMethod void testCaseContact2() {
        
        Set<Id> rMTMIds = new Set<Id>();
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        //Account minor restriction, Contact severe restriction.
        //Util.IsTesting = true;
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test Case Account 1';
        insert acc;
        
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Critical Background Information';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;
        
        Restrictions__c rest2 = new Restrictions__c();
        rest2.Category__c = 'Restricted: Permission Required';
        rest2.Expiration_Date__c = system.today().addDays(10);
        insert rest2;
        
        rest2 = [select id, Status__c, Category__c from Restrictions__c where id = :rest2.id];
        system.assertEquals('Active', rest2.Status__c);
        
        Contact cnt = new Contact();
        cnt.LastName = 'Test';
        cnt.AccountId = acc.Id;
		cnt.Email = 'Test'+Math.random()+'@eab.com';
		cnt.Title = 'Test';
		cnt.Phone = '614-555-8855';
        insert cnt;
    
        //acct restriction, info alert level
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = accRestrictionRecordType.ID;
        restMtM.Account__c = acc.Id;
        restrictionMtMs.add(restMtM);
        
        //cnt = [select id, Contact_Restriction_Status__c from Contact where Id =: cnt.Id];
        //System.assertEquals('Account - Critical Background Information', cnt.Contact_Restriction_Status__c );
        
        //contact restriction, restricted level
        restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest2.Id;
        restMtM.RecordTypeId = conRestrictionRecordType.ID;
        restMtM.Contact__c = cnt.Id;
        restrictionMtMs.add(restMtM);
        
        //Test will start from here
        test.startTest();
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
        
        //Inserting restrcited MTM's
        insert restrictionMtMs;
        
        //Test will stop here
        Test.stopTest();
    
        cnt = [select id, Contact_Restriction_Status__c from Contact where Id =: cnt.Id];
        System.debug('Contact : '+cnt);
    
        System.assertEquals('Restricted: Permission Required', cnt.Contact_Restriction_Status__c );
    }
    
    static testMethod void testCaseContact3() {
        
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Contact minor restriction
        Util.IsTesting = true;
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        
        Account acc2 = new Account();
        acc2.Name = 'Test Case Account 1';
        insert acc2;
        
        Contact cnt2 = new Contact();
        cnt2.LastName = 'Test';
        cnt2.AccountId = acc2.Id;
		cnt2.Email = 'Test'+Math.random()+'@eab.com';
		cnt2.Title = 'Test';
		cnt2.Phone = '614-555-8855';
        insert cnt2;
    
        Restrictions__c rest2 = new Restrictions__c();
        rest2.Category__c = 'Critical Background Information';
        rest2.Expiration_Date__c = system.today().addDays(10);
        insert rest2;
    
        //Test will start from here
        Test.startTest();
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
    
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest2.Id;
        restMtM.RecordTypeId = conRestrictionRecordType.ID;
        restMtM.Contact__c = cnt2.Id;
        insert restMtM;
        
        //test will stop here
        test.stopTest();
    
        Contact cnt4 = [select id, Contact_Restriction_Status__c from Contact where Id =: cnt2.Id];
        System.debug('Contact : '+cnt4);
    
        System.assertEquals('Critical Background Information', cnt4.Contact_Restriction_Status__c);
    }
    
    //Ajit Surana - 03/12/2014 - CR-20140204-4450 - Test method modified 
    static testMethod void testCaseContact4() {
        
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        
        //Ajit Surana - 03/12/2014 - CR-20140204-4450 
        //Insert Restriction record
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Restricted: Permission Required';
        rest1.Source_Department__c = 'RI Marketing';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;
        
        //Insert Account record
        Account acc2 = new Account();
        acc2.Name = 'Test Case Account 1';
        insert acc2;
        
        //Insert bunch of Contact records to a single Account
        List<Contact> contactList = new List<Contact>();
        
        //Prepare data for bulk insertion
        for(Integer i = 0; i < 10; i++)
            contactList.add(new Contact(LastName = 'TestData'+i, AccountId = acc2.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        
        insert contactList;
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
    
        //Insert RestrictionMtM record
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = accRestrictionRecordType.ID;
        restMtM.Account__c = acc2.Id;
        insert restMtM;
        
        //Test starts from here
        Test.startTest();
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = false;
        
        //Delete RestrictionMtM record
        delete restMtM;
        
        //Query for Account and Contact Restriction status
        List<Account> accList = [SELECT Id, Account_Restriction_Status__c FROM Account WHERE Id =: acc2.Id];
        
        List<Contact> conList = [SELECT Id, Contact_Restriction_Status__c FROM Contact WHERE Id IN: contactList];
        
        //Assert for results 
        System.assertEquals(null, accList[0].Account_Restriction_Status__c);
        System.assertEquals(null, conList[0].Contact_Restriction_Status__c);
        
        //Test stops here
        Test.stopTest();  
    }
    
    static testMethod void testCaseContact5() {
        
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = true;
        
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Restricted: Permission Required';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;
    
        Account acc2 = new Account();
        acc2.Name = 'Test Case Account 1';
        insert acc2;
    
        Contact cnt5 = new Contact();
        cnt5.LastName = 'Test';
        cnt5.AccountId = acc2.Id;
		cnt5.Email = 'Test'+Math.random()+'@eab.com';
		cnt5.Title = 'Test';
		cnt5.Phone = '614-555-8855';
        insert cnt5;
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
    
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = conRestrictionRecordType.ID;
        restMtM.Contact__c = cnt5.Id;
        insert restMtM;
    
        Contact cnt6 = [select id, Contact_Restriction_Status__c from Contact where Id =: cnt5.Id];
        System.debug('Contact : '+cnt5);
        System.assert(cnt6.Contact_Restriction_Status__c == 'Restricted: Permission Required','Test Failed as Trigger dint function properly for Contact ');
        
        //test will start from here
        Test.startTest();
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
        
        //deleting restricted MTM's
        delete restMtM; 
        
        //test will stop here
        Test.stopTest();
    }
}