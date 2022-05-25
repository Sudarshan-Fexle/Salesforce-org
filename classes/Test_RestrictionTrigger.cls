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
/**
 *  Purpose         :   Test class for Trigger_Restriction
 *
 *  Create By       :  
 *
 *  Created Date    :   
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - 7/20/2016 - CR-20150202-8640 - A code refactor CR
 *                      v_1.2 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
 *
 *  Coverage       :    V_1.0 - 13% - RestrictionTriggerHelper
 *                      V_1.1 - 93% - RestrictionTriggerHelper
 *                       
 **/
@isTest(seeAllData=false)
private class Test_RestrictionTrigger {

    //Modified By - Abhinav Sharma - 7/20/2016 - CR-20150202-8640 - A code refactor CR
    /** Description - Test Trigger_Restriction process to update Owner Detail on Restriction records 
     **/
    static testmethod void testUpdateOwnerDetailsField() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Dupeblocker and disbaling triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Create test data
        List<Restrictions__c> restrictions = new List<Restrictions__c>();
        
        //prepare data for bulk insertion
        for(Integer i = 0; i < 20; i++)
            restrictions.add(new Restrictions__c(Name = 'TestData'));
            
        //start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAlltriggers = false;
        
        //insert data in bulk
        insert restrictions;
        
        //retrieve the restrictions records
        restrictions = [Select Owner_Details__c, OwnerId from Restrictions__c where Id in: restrictions];
       
        //loop through the records and assert the results
        for(Restrictions__c restriction : restrictions) {
            System.assert(restriction.Owner_Details__c != null);
            System.assertEquals(restriction.OwnerId, restriction.Owner_Details__c);
        }
        
        //fetch the another user of the same profile and update the current records
        //to test the Owner_Details__c field in update case
        List<User> listUser = [Select Id from User where Id !=: UserInfo.getUserId() and ProfileId =: UserInfo.getProfileId()];
        
        //check for the user size
        if(listUser != null && listUser.size() > 0) {
            
            //loop through the result and assert the result
            for(Restrictions__c restriction : restrictions) {
                restriction.OwnerId = listUser[0].Id;
            }
            
            //update the records in bulk
            update restrictions;
            
            //retrieve the restrictions records
            restrictions = [Select Owner_Details__c, OwnerId from Restrictions__c where Id in: restrictions];
            
            //loop through the records and assert the results
            for(Restrictions__c restriction : restrictions) {
                System.assert(restriction.Owner_Details__c != null);
                System.assertEquals(restriction.OwnerId, restriction.Owner_Details__c);
            }
        }
        
        //stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 7/20/2016 - CR-20150202-8640 - A code refactor CR
    /** Description - Test Trigger_Restriction process to update associated account record "Account_Restriction_Status__c" field value.
     **/
    static testmethod void testunit() {
        
        //Bypass Dupeblocker and disbaling triggers for test data creation purpose
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Bypass trigger
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        
        //Create Restriction records
        Restrictions__c newrestriction = new Restrictions__c(
            category__c = 'Restricted: Permission Required', 
            Name = 'A', 
            Reason__c = 'Other', 
            Source_Department__c = 'Other', 
            Expiration_Date__c = System.today().addDays(1)
        );
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert Restriction record
        insert newrestriction;
        
        //Crea Account record
        Account a = new Account(
            Name = 'testacct'
        );
        
        //Insert
        insert a;
        
        //Query over Restricted object recordType 
        Recordtype rt = [SELECT id FROM Recordtype WHERE SObjectType = 'Restricted_MtM__c' 
                            AND Name = 'Account Restriction'
                            AND IsActive = true  limit 1];
                            
        //Asserting for the results
        System.assert(rt != null);
        
        //Created Restricted MtM Record
        Restricted_MtM__c newrmtm = new Restricted_MtM__c(
            RecordtypeId = rt.id,
            Restriction__c = newrestriction.id,
            Account__c = a.id,
            Restriction_Expired__c = true
        );
        
        //bypass trigger flag
        Util.BypassAllTriggers = true;
        
        //Insert Restricted Record
        insert newrmtm;
        
        //Enable trigger again
        Util.BypassAllTriggers = false;
        
        //Set value to update record
        newrestriction.Run_Trigger__c = true;
        newrestriction.Expiration_Date__c = system.today().addDays(-1);
        
        //Test method start here
        test.startTest();
        
        //Update record      
        update newrestriction;
        
        //Enable Trigger flag
        Util.BypassAllTriggers = false;
        
        //Set value to update on record
        newrestriction.Expiration_Date__c = system.today().addDays(1);
        
        //Update Restricted record
        update newrestriction;
        
        //Query over acount
        a = [select Account_Restriction_Status__c from Account where id = :a.id];
        
        //Assert for result
        System.assert(a != null);
        system.assertEquals('Restricted: Permission Required'   , a.Account_Restriction_Status__c);
        
        //Test method stop here
        test.stopTest();
    }   
    
    //Modified By - Abhinav Sharma - 7/20/2016 - CR-20150202-8640 - A code refactor CR
    /** Description - Test Trigger_Restriction process to update associated contact record "Contact_Restriction_Status__c" field value, on restriction MTM record(s) delete.
     **/
    static testMethod void testCaseContact4() {
        
        //Bypass Dupeblocker and disbaling triggers for test data creation purpose
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
      
        //Added by Ajit Surana - 05/03/2014 - CR-20140418-5151
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
                                                
        //Assert for result
        System.assert(accRestrictionRecordType != null);
        System.assert(conRestrictionRecordType != null);
        
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
        
        //Insert
        insert contactList;
        
        //Asserting for the results
        System.assert(contactList != null);
        System.assert(contactList.size() > 0);
        
        //Enabling all triggers
        util.BypassAllTriggers = false;
    
        //Insert RestrictionMtM record
        Restricted_MtM__c restMtM = new Restricted_MtM__c();
        restMtM.Restriction__c = rest1.Id;
        restMtM.RecordTypeId = accRestrictionRecordType.ID;
        restMtM.Contact__c = contactList[0].Id;
        insert restMtM;
        
        //Test starts from here
        Test.startTest();
        
        //Set flag false for not to by pass all triggers
        util.BypassAllTriggers = false;
        
        //Delete RestrictionMtM record
        delete restMtM;
        
        //Query for Account and Contact Restriction status
        List<Account> accList = [SELECT Id, Account_Restriction_Status__c 
                                    FROM Account WHERE Id =: acc2.Id];
        
        List<Contact> conList = [SELECT Id, Contact_Restriction_Status__c 
                                    FROM Contact WHERE Id IN: contactList];
        
        //Assert for results
        System.assert(accList != null);
        System.assert(accList.size() > 0);
        System.assert(conList != null);
        System.assert(conList.size() > 0);
        System.assertEquals(null, accList[0].Account_Restriction_Status__c);
        System.assertEquals(null, conList[0].Contact_Restriction_Status__c);
        
        //Test stops here
        Test.stopTest();  
    }
    
   //Added By - Abhinav Sharma - 7/20/2016 - CR-20150202-8640 - A code refactor CR
    /** Description -   Test Trigger_restricted process to update the accounts and the contacts associated with restriction when Restriction record got deleted. 
    **/
    static testMethod void testDeleteRestrictionsProcess() {
        
        //By pass dupeblocker and triggers
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                    WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                    WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
                                                    
        //Assert for result
        System.assert(accRestrictionRecordType != null);
        System.assert(conRestrictionRecordType != null);
        
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Added record in list
        accounts.add(new Account(Name = 'Test Case Account 1', Account_Restriction_Status__c = 'Account res 1'));
        accounts.add(new Account(Name = 'Test Case Account 2', Account_Restriction_Status__c = 'Account res 2'));
        accounts.add(new Account(Name = 'Test Case Account 3', Account_Restriction_Status__c = 'Account res 3'));
        
        //Insert
        insert accounts;
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Added record in list
        contacts.add(new Contact(LastName = 'contact 1', AccountId = accounts[0].Id, Contact_Restriction_Status__c = 'Contact res 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(LastName = 'contact 2', AccountId = accounts[1].Id, Contact_Restriction_Status__c = 'Contact res 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(LastName = 'contact 3', AccountId = accounts[2].Id, Contact_Restriction_Status__c = 'Contact res 3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;
        
        //Insert Restriction record
        List<Restrictions__c> restrictions = new List<Restrictions__c>();
        
        //Added records in lists
        restrictions.add(new Restrictions__c(Name = 'Restriction 1', Category__c = 'Restricted: Permission Required',Source_Department__c = 'RI Marketing', Expiration_Date__c = system.today().addDays(10)));
        restrictions.add(new Restrictions__c(Name = 'Restriction 2', Category__c = 'Restricted: Permission Required',Source_Department__c = 'RI Marketing', Expiration_Date__c = system.today().addDays(10)));
        
        //Insert
        insert restrictions;
        
        //Insert RestrictionMtM record
        List<Restricted_MtM__c> restrictedMtMs = new List<Restricted_MtM__c>();
        
        //Add record in list
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Contact__c = contacts[0].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[1].Id, Contact__c = contacts[1].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        
        //Insert
        insert restrictedMtMs;
        
        //Test starts from here
        Test.startTest();
        
        //By pass trigger
        util.BypassAllTriggers = false;
        
        //Assert for result
        System.assert(accounts != null);
        System.assert(accounts.size() > 0);
        System.assert(contacts != null);
        System.assert(contacts.size() > 0);
        System.assertEquals('Account res 1',accounts[0].Account_Restriction_Status__c);
        System.assertEquals('Contact res 1',contacts[0].Contact_Restriction_Status__c);
        
        //Delete
        delete restrictions[0];
        
        //By pass trigger
        util.BypassAllTriggers = true;
        
        //Query over restrictions
        List<Restrictions__c> restrictionList = [Select ID from Restrictions__c ORDER by Name];
        
        //Assert for result
        System.assert(restrictionList != null);
        System.assertEquals(1, restrictionList.size());
        
        //Querly over Account
        List<Account> accList = [Select Id, Account_Restriction_Status__c from Account ORDER By Name];
        
        //Assert for result
        System.assert(accList != null);
        System.assertEquals(3, accList.size());
        System.assertEquals(null,accList[0].Account_Restriction_Status__c);
        
        //Query on Contact
        List<Contact> conList = [Select Id, Contact_Restriction_Status__c from Contact ORDER BY Name];
        
        //Assert for result
        System.assert(conList != null);
        System.assertEquals(3, conList.size());
        System.assertEquals(null,conList[0].Contact_Restriction_Status__c);
        
        //Test Method stop here
        Test.stopTest();
        
    }
    
    //Added By - Mahendra Swarnkar - 7/16/2016 - CR-20150202-8640
    /** Description     -   Test Trigger_Restriction process to update restriction status for the contacts and accounts associated with the restricted MtM records. 
     **/
    static testMethod void testDeleteRestrictionMtMsProcess() {
        
        //By pass dupeblocker and triggers
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
    
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                                WHERE SobjectType = 'Restricted_MtM__c' AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
                                                
        //Assert for result
        System.assert(accRestrictionRecordType != null);
        System.assert(conRestrictionRecordType != null);
        
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Added record in list
        accounts.add(new Account(Name = 'Test Case Account 1', Account_Restriction_Status__c = 'Account res 1'));
        accounts.add(new Account(Name = 'Test Case Account 2', Account_Restriction_Status__c = 'Account res 2'));
        accounts.add(new Account(Name = 'Test Case Account 3', Account_Restriction_Status__c = 'Account res 3'));
        
        //Insert
        insert accounts;
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Added record in list
        contacts.add(new Contact(LastName = 'contact 1', AccountId = accounts[0].Id, Contact_Restriction_Status__c = 'Contact res 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(LastName = 'contact 2', AccountId = accounts[1].Id, Contact_Restriction_Status__c = 'Contact res 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(LastName = 'contact 3', AccountId = accounts[2].Id, Contact_Restriction_Status__c = 'Contact res 3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;
        
        //Insert Restriction record
        List<Restrictions__c> restrictions = new List<Restrictions__c>();
        
        //Added records in lists
        restrictions.add(new Restrictions__c(Name = 'Restriction 1', Category__c = 'Restricted: Permission Required',Source_Department__c = 'RI Marketing', Expiration_Date__c = system.today().addDays(10)));
        restrictions.add(new Restrictions__c(Name = 'Restriction 2', Category__c = 'Restricted: Permission Required',Source_Department__c = 'RI Marketing', Expiration_Date__c = system.today().addDays(10)));
        
        //Insert
        insert restrictions;
        
        //Insert RestrictionMtM record
        List<Restricted_MtM__c> restrictedMtMs = new List<Restricted_MtM__c>();
        
        //Add record in list
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Contact__c = contacts[0].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[1].Id, Contact__c = contacts[1].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        restrictedMtMs.add(new Restricted_MtM__c(Restriction__c = restrictions[0].Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        
        //Insert
        insert restrictedMtMs;
        
        //Test starts from here
        Test.startTest();
        
        //By pass trigger
        Util.BypassAllTriggers = false;
        
        //Delete
        delete restrictedMtMs[0];
        
        //Assert for result
        System.assert(accounts != null);
        System.assert(accounts.size() > 0);
        System.assert(contacts != null);
        System.assert(contacts.size() > 0);
        System.assertEquals('Account res 1',accounts[0].Account_Restriction_Status__c);
        System.assertEquals('Contact res 1',contacts[0].Contact_Restriction_Status__c);
        
        //Querly over Account
        List<Account> accList = [Select Id, Account_Restriction_Status__c from Account ORDER By Name];
        
        //Assert for result
        System.assert(accList != null);
        System.assertEquals(3, accList.size());
        System.assertEquals('Restricted: Permission Required',accList[0].Account_Restriction_Status__c);
        
        //Query on Contact
        List<Contact> conList = [Select Id, Contact_Restriction_Status__c from Contact ORDER BY Name];
        
        //Assert for result
        System.assert(conList != null);
        System.assertEquals(3, conList.size());
        System.assertEquals('Account - Restricted: Permission Required',conList[0].Contact_Restriction_Status__c);
        
        //Query for Restricted MtM
        List<Restricted_MtM__c> restrictedMtMsList = [Select Id from Restricted_MtM__c];
        
        //Assert for result
        System.assert(restrictedMtMsList != null);
        system.assertEquals(3, restrictedMtMsList.size());
        
        //Test method here
        Test.StopTest();
    }
}