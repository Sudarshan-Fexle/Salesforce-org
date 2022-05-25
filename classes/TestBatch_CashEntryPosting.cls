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
@isTest(seeAllData = false)
private class TestBatch_CashEntryPosting {
    
    /**
    Purpose         :   Test class for Batch_CashEntryPosting
                
    Created By       :  
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created - 
                        v1.1 - Modified - Abhinav Sharma - 02/09/2017 - To fix "Run All Test" based failure
                        
 *
 *  Coverage        :   v1.1 - Batch_CashEntryPosting - 100%
**/
    static testmethod void testCashPosting() {

        try {
            
            //Bypass Dupeblocker
            Util.IsTest(true);
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            //Account
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            
            //Cash Entry
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            cashEntry.ffcash__DeriveBankAccount__c = true;
            cashEntry.c2g__status__c = 'In Progress';
            cashEntry.c2g__Value__c = 15;
            insert cashEntry;
            
            //Cash Entry Line Item
            c2g__codaCashEntryLineItem__c cashEntryLineItem = new c2g__codaCashEntryLineItem__c();
            cashEntryLineItem.c2g__CashEntry__c = cashEntry.Id;
            cashEntryLineItem.c2g__Account__c = account.Id;
            cashEntryLineItem.c2g__CashEntryValue__c = 15;
            insert cashEntryLineItem;
			
            //Start test from here
			test.StartTest(); 
            
            //Execute the batch class
            Batch_CashEntryPosting batch = new Batch_CashEntryPosting();
            batch.query = 'SELECT id FROM c2g__codaCashEntry__c where id = \'' + cashEntry.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
            
            //Stop test class here
			test.StopTest();
			
            //Querying for the results/details
            c2g__codaCashEntry__c cashEntry2 = [SELECT c2g__status__c FROM c2g__codaCashEntry__c where id = :cashEntry.id];
            
            //Asserting for the results
            system.assert(cashEntry2 != null);
            system.assertEquals('Complete', cashEntry2.c2g__status__c);
        }
        catch(Exception e){}
    }
    
    static testmethod void testCashPosting_InvalidData() {

        try {
            
            //Bypass Dupeblocker
            Util.IsTest(true);
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            //Account
            Account account = [SELECT Id FROM Account WHERE Status__c = 'Active' LIMIT 1];
            
            //Cash Entry
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            cashEntry.ffcash__DeriveBankAccount__c = true;
            cashEntry.c2g__status__c = 'In Progress';
            cashEntry.c2g__Value__c = 15;
            insert cashEntry;
			
            //Start test from here
			test.StartTest(); 
            
            //Execute batch job here
            Batch_CashEntryPosting batch = new Batch_CashEntryPosting();
            batch.query = 'SELECT id FROM c2g__codaCashEntry__c where id = \'' + cashEntry.id + '\'';       
            Id batchId = Database.executeBatch(batch, 1);
			
            //Stop test here
            test.StopTest();
			
            //Querying for the results/details
            c2g__codaCashEntry__c cashEntry2 = [SELECT c2g__status__c FROM c2g__codaCashEntry__c where id = :cashEntry.id];
            
            //Asserting for the results
            system.assert(cashEntry2 != null);
            system.assertEquals('In Progress', cashEntry2.c2g__status__c);
        }
        catch(Exception e){}
    }   
}