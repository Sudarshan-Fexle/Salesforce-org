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
/*  Description     :   Test class for Batch_ConvertAttachmentsToFiles and Batch_ConvertNotesToFiles
 *
 *   Created by      :   Mahendra Swarnkar
 *
 *   Created Date    :   01/03/2020
 *
 *   Revision Log    :   
 */
@isTest
private class Test_Batch_ConvertAttachmentsToFiles{

  //test method
    static testMethod void unitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(Origin = 'ABC', Subject = 'Test', Description = 'Test', AccountId = accounts[0].Id);
        
        //Populating list with case records
        cases.add(aCase_1);
        
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 1);
        
        //Attachment istance
        Attachment attach = new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = cases[0].id;
        attach.ContentType = '.pdf';
        
        insert attach;
        
        //Note instance
        Note nt = new Note();     
        nt.Title='Unit Test Attachment';
        nt.body = 'Unit Test Attachment Body';
        nt.parentId = accounts[0].id;
        
        insert nt;
        
        Id userId = TestUtilities.CreatenewUser(true).Id;
        
        Set<Id> setUserId = new Set<Id>();
        setUserId.add(userId);
        
        //Start our Test
        Test.startTest();
        
        //Run our Batch
        Batch_ConvertAttachmentsToFiles testBatch = new Batch_ConvertAttachmentsToFiles('', new List<String>{'Case'});
        Database.executeBatch(testBatch);
        
        Test.stopTest();
       
    }
}