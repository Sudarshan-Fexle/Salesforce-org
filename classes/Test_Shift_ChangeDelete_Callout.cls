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
//Modified By Rajeev Jain - CR-20180917-12604 - Removed the references of Royall Resource.

@isTest(seeAllData=false)
public class Test_Shift_ChangeDelete_Callout {
    
	static testmethod void testCallout() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //create some records
        List<Account> accountList = new List<Account>();
        
        //Loop through integer variable for creating multiple instances and populating list with it
        for(Integer x=0; x<10; x++) {
            accountList.add(new Account (Name='test'));
        }
        insert accountList;
        
        //configure settings
        Shift_ChangeDelete_Callout.calloutSettings = new rest_callout_config__c(    SetupOwnerId = Userinfo.getUserId(),
                                                                AppKey__c = 'sftrigger',
                                                                Username__c = 'sftrigger',
                                                                Password__c = 'sftrigger',
                                                                Endpoint__c = 'https://api.royall.com/salesforce/v1/update/');
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Processing records
        Shift_ChangeDelete_Callout.processRecords( (List<SObject>)accountList, 'update', 'Account');
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By Rajeev Jain - CR-20180917-12604 - Removed the references of Royall Resource.
    static testmethod void test_triggerCoverage() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Shift change delete callout record
        Shift_ChangeDelete_Callout.calloutSettings = new rest_callout_config__c( Enable_Account_Trigger__c = true,
                                                                                 Enable_Contact_Trigger__c = true,
                                                                                 Enable_Resource_Trigger__c = true,
                                                                                 Enable_User_Trigger__c = true,
                                                                                    AppKey__c = '31ED9C1ED3A9B66F3B68145762474BB4',
                                                                                    Username__c = 'sftrigger',
                                                                                    Password__c = 'S6rxysCN34DQ',
                                                                                    Endpoint__c = 'https://api.royall.com/salesforce/v1/update/');
        //create some records
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        /*List<Royall_Resource__c> rrList = new List<Royall_Resource__c>();
        
        for(Integer x=0; x<5; x++) {
            Account tempAccount = new Account (Name='test');
            accountList.add(tempAccount);
            
            rrList.add(new Royall_Resource__c(Name=string.valueOf(x),Email__c='test'+string.valueOf(x)+'@test.com', Employee_Number__c=x));
        } */
        
        //Start test from here
        Test.startTest();
        
        //Start testing from here
        Util.byPassAllTriggers = false;
        
        try {
            insert accountList;
            //insert rrList;
        } catch (Exception e) {
            system.debug(e);
        }
        
        for(Account tempAccount : accountList) {
            Contact tempContact = new Contact(AccountId = tempAccount.id, LastName='test');
            contactList.add(tempContact);
        }
        
        try {        
            insert contactList;
            update accountList;
            update contactList;
            //update rrList;
        } catch (Exception e) {
            system.debug(e);
        }        
        
        User tempUser = [SELECT id FROM User WHERE Id=:Userinfo.getUserId() LIMIT 1];
        update tempUser;
        
        try {
            //delete rrList;
            delete contactList;
            delete accountList;
        } catch (Exception e) {
            system.debug(e);
        }

		//Stop test here
		Test.stopTest();        
    }
}