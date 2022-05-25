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
 *  Description     :   Test class for AccountRelationshipTriggerHelper
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   02/02/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150116-8581
 *
 *  Coverage        :   V_1.0 - AccountRelationshipTriggerHelper - 100%
 **/
@isTest(seeAllData = false)
private class Test_AccountRelationshipTriggerHelper {
    
    static testmethod void test_validateReplationshipPresence() {
        
        //skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Institution
        Account testAccount = new Account(Name = 'Test Acc 1', Account_Formal_Name__c = 'testAcc1');
        
        //Third Party Institution
        Account thirdPartyAcc1 = new Account(Name = 'Test Acc 2', Account_Formal_Name__c = 'testAcc2');
        Account thirdPartyAcc2 = new Account(Name = 'Test Acc 3', Account_Formal_Name__c = 'testAcc3');
        
        //List of Accounts
        List<Account> accounts = new List<Account>();
        accounts.add(testAccount);
        accounts.add(thirdPartyAcc1);
        accounts.add(thirdPartyAcc2);
        insert accounts;
        
        //Create Account Relationship test data
        List<AccountRelationship__c> testAccRelationships = new List<AccountRelationship__c>();
        
        //Create test data
        testAccRelationships.add(new AccountRelationship__c(Institution__c = accounts[0].Id, 
                                    Third_Party__c = accounts[1].Id));
        testAccRelationships.add(new AccountRelationship__c(Institution__c = accounts[0].Id, 
                                    Third_Party__c = accounts[2].Id));
        
        //Test starts from here
        Test.startTest();
                                                          
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Insert account relationships 
        insert testAccRelationships;
        
        //Querying for the account relationship fields value
        testAccRelationships = [SELECT Id, Third_Party__c, Institution__c 
                                    FROM AccountRelationship__c ORDER BY Name ASC LIMIT 5];
        
        //Assert for results
        System.assertEquals(2, testAccRelationships.size());
        System.assertEquals(thirdPartyAcc1.Id, testAccRelationships[0].Third_Party__c);
        System.assertEquals(thirdPartyAcc2.Id, testAccRelationships[1].Third_Party__c);
        
        //Create another test data
        testAccRelationships =  new List<AccountRelationship__c>();
        testAccRelationships.add(new AccountRelationship__c(Institution__c = testAccount.Id, 
                                    Third_Party__c = thirdPartyAcc1.Id));
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Insert data 
        try {
            insert testAccRelationships;
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.ERROR_Third_Party));
        }
        
        //Test stops here
        Test.stopTest();
    }
}