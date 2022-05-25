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
@isTest(seeAllData=false)
private class Test_Batch_CheckRestrictionExpiration {
    /**
        Purpose         :   Test class for Batch_CheckRestrictionExpiration
                    
        Create By       :   Abhinav Sharma
        
        Created Date    :   06/17/2015
        
        Revision Log    :   V_1.0 - Created - Abhinav Sharma - CR-20150422-8901
	                :   V_1.1 - Modified By - Abhisekh Mishra - CR-20210517-15149 - 06/02/2021 - To increase code coverage - CR-20210517-15150
    **/
    
    static testmethod void Batch_CheckRestrictionExpirationTest() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        // update restriction so that it is expired
        util.BypassAllTriggers = true;
        
        Account a = new Account(Name = 'DrewTestAccount', Account_Formal_Name__c = 'DrewTestAccount');
        insert a;
        
        Contact c = new Contact(LastName = 'TestContact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert c;

        Restrictions__c r = new Restrictions__c(Expiration_Date__c = Date.today().addDays(5));
        insert r;

        Restricted_MtM__c rmtm = new Restricted_MtM__c(Account__c = a.Id, Contact__c = c.Id, Restriction__c = r.Id, Restriction_Expired__c = false);
        insert rmtm;
        
        r = [SELECT Id, Expiration_Date__c FROM Restrictions__c WHERE Id = :r.Id];
        
        r.Expiration_Date__c = system.today().addDays(-2);
        update r;
        util.BypassALltriggers = false;
        
        r = [SELECT Id, Expiration_Date__c FROM Restrictions__c WHERE Id = :r.Id];
        
        //Assert for the results
        system.assertEquals(system.today().addDays(-2), r.Expiration_Date__c);
        system.assertEquals(r.Id, rmtm.Restriction__c);
            
        //test will start from here
        test.StartTest();
        
        //Execute Batch
        Batch_CheckRestrictionExpiration batch = new Batch_CheckRestrictionExpiration();
        Database.executeBatch(batch,200);
        
        //Test will stop here
        test.StopTest();
        
        //Querying for the updated fields values and applying asserts accordingly
        Restricted_MtM__c retrmtm = [select Restriction_Expired__c, Restriction__r.Expiration_Date__c from Restricted_MtM__c where Id = :rmtm.Id];
        system.assertEquals(true, retrmtm.Restriction_Expired__c);
	}
    
    //Added by Abhisekh Mishra - CR-20210517-15149 - 06/07/2021 - To increase the code coverage - CR-20210517-15150
    static testmethod void Batch_RestrictionUpdate() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //update restriction so that it is expired
        util.BypassAllTriggers = true;
        
        //List to hold account records
        List<Account> accounts = new List<Account>();
        
        //Add account records into the list
        accounts.add(new Account(Name = 'DrewTestAccount', Account_Formal_Name__c = 'DrewTestAccount', Account_Restriction_Status__c = 'test'));
        accounts.add(new Account(Name = 'DrewTestAccount2', Account_Formal_Name__c = 'DrewTestAccount2', Account_Restriction_Status__c = 'test'));
        accounts.add(new Account(Name = 'DrewTestAccount3', Account_Formal_Name__c = 'DrewTestAccount3', Account_Restriction_Status__c = 'test'));
        
        //insert account record
        insert accounts;
        
        //List to hold contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add contact records into the list
        contacts.add(new Contact(LastName = 'TestContact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Contact_Restriction_Status__c = 'test'));
        contacts.add(new Contact(LastName = 'TestContact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test2', Phone = '614-555-8876', Contact_Restriction_Status__c = 'test'));
        contacts.add(new Contact(LastName = 'TestContact3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test3', Phone = '614-555-8976', Contact_Restriction_Status__c = 'test'));
        
        //insert contact records 
        insert contacts;
        
        //List to hold restriction records
        List<Restrictions__c> restrictions = new List<Restrictions__c>();
        
        //Add restriction record into the list
        restrictions.add(new Restrictions__c(Expiration_Date__c = Date.today().addDays(-2)));
        restrictions.add(new Restrictions__c(Expiration_Date__c = Date.today().addDays(-3)));
        restrictions.add(new Restrictions__c(Expiration_Date__c = Date.today().addDays(-4)));
        
        //insert restriction records
        insert restrictions;
        
        //List to hold restriction mtm records
        List<Restricted_MtM__c> restrictedMtm = new List<Restricted_MtM__c>();
        
        //Add restriction mtm records into the list
        restrictedMtm.add(new Restricted_MtM__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Restriction__c = restrictions[0].Id, Restriction_Expired__c = false));
        restrictedMtm.add(new Restricted_MtM__c(Account__c = accounts[1].Id, Contact__c = contacts[1].Id, Restriction__c = restrictions[1].Id, Restriction_Expired__c = false));
        restrictedMtm.add(new Restricted_MtM__c(Account__c = accounts[2].Id, Contact__c = contacts[2].Id, Restriction__c = restrictions[2].Id, Restriction_Expired__c = false));
        
        //trigger enabled
        util.BypassAllTriggers = false;
        
        //insert restriction mtm records
        insert restrictedMtm;
        
        //test will start from here
        test.StartTest();
        
        //Set to hold restriction mtm records
        Set<Id> rMTMIdSet = new Set<Id>();
        rMTMIdSet.add(restrictedMtm[0].Id);
        rMTMIdSet.add(restrictedMtm[1].Id);
        rMTMIdSet.add(restrictedMtm[2].Id);
        
        //Execute batch
        Batch_RestrictionUpdate bb = new Batch_RestrictionUpdate(rMTMIdSet);
        bb.IsDelete = true;
        database.executeBatch(bb, 3);
        
        //test will end from here
        test.stopTest();
        
        //Fetched accounts through SOQL and added assert
        List<Account> listAccount = [SELECT Id, Account_Restriction_Status__c From Account];
        System.assertEquals(null,listAccount[0].Account_Restriction_Status__c);
        System.assertEquals(null,listAccount[1].Account_Restriction_Status__c);
        System.assertEquals(null,listAccount[2].Account_Restriction_Status__c);
        
        //Fetched contacts through SOQL and added assert
        List<Contact> listContact = [SELECT Id, Contact_Restriction_Status__c From Contact];
        System.assertEquals(null,listContact[0].Contact_Restriction_Status__c);
        System.assertEquals(null,listContact[1].Contact_Restriction_Status__c);
        System.assertEquals(null,listContact[2].Contact_Restriction_Status__c);
        
        //Fetched restricted mtm through SOQL and added assert
        List<Restricted_MtM__c> listRestrictionMtm = [Select Id From Restricted_MtM__c];
        System.assertEquals(0, listRestrictionMtm.size());
    }
}