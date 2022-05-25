/*
    Purpose:    Test Class for Batch_PopulateRNIAMRestrictionsOnAccount - CR-20111006-148
    
    Create By:  Simplyforce - Bhavi - 12/15/2011
    
    Current Version:    v1.0
    
    Revision Log:       Created.
*/
    
@isTest
private class Test_BatchPopulateRNIAMRestrictionsOnAcc {
    
    //test method
    static testmethod void myUnitTest() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account account = new Account(Name = 'TestAccountName');
        insert account;
        
        //insert restricted data
        Restrictions__c restriction = new Restrictions__c(Name = 'Test Restrictions', Category__c = 'Restricted: Permission Required', Source_Department__c = 'EA', Expiration_Date__c = Date.today().addDays(1));
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id );
        
        //insert restricted data
        restriction = new Restrictions__c(Name = 'Test Restrictions', Expiration_Date__c = Date.today().addDays(1), Category__c = 'Restricted: Permission Required', Source_Department__c = 'AE');
        insert restriction;
        
        //Restricted_MtM__c test data
        insert new Restricted_MtM__c(Restriction__c = restriction.Id, Account__c = account.Id);
        
        // retire restriction
        restriction = [SELECT Expiration_Date__c FROM Restrictions__c WHERE Id = :restriction.Id];
        restriction.Expiration_Date__c = system.today().addDays(-1);
        update restriction;
        
        //start test from here
        Test.startTest();
        
        //execute the batch process
        ID batchProcessId = Database.executeBatch(new Batch_PopulateRNIAMRestrictionsOnAccount(), 10);
        
        //Stop test here 
        Test.stopTest();
        
        //assert the results
        System.assertEquals(1, [Select RNI_AM_Restrictions__c from Account where Id =: account.Id][0].RNI_AM_Restrictions__c);
    }
}