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
private class Test_Batch_CashEntryDiscarding {
    
    @isTest
    static void testCashEntry() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = testUtilities.CreateNewUser(p, true);
        user.LastName = 'Saweda';
        update user;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User.Id);
        
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda' Limit 1];
        
        System.runAs(user1) {
            
            c2g__codaGeneralLedgerAccount__c cGLA = new c2g__codaGeneralLedgerAccount__c(c2g__CashFlowCategory__c = 'Other' , Active__c = true , c2g__Type__c = 'Balance Sheet' , c2g__AdjustOperatingActivities__c = true , c2g__AllowRevaluation__c = true , c2g__ReportingCode__c = 'AAA');
            insert cGLA;
            
            
            c2g__codaAccountingCurrency__c pCurrency = [Select Id From c2g__codaAccountingCurrency__c WHERE Name='USD' LIMIT 1];
            
            c2g__codaPeriod__c pPeriod = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__StartDate__c<=:System.today() AND c2g__EndDate__c>=:System.today() LIMIT 1]; 
            
            List<c2g__codaBankAccount__c> listOfBankAccount = new List<c2g__codaBankAccount__c>();
            listOfBankAccount.add(new c2g__codaBankAccount__c(c2g__BankAccountCurrency__c = pCurrency.ID,c2g__GeneralLedgerAccount__c = cGLA.ID , c2g__AccountName__c = 'Bank Account 1' ,c2g__ReportingCode__c = 'GB1',  c2g__AccountNumber__c = '80775676555' , c2g__BankName__c = 'Global Bank Pvt. Ltd. 1'));
            listOfBankAccount.add(new c2g__codaBankAccount__c(c2g__BankAccountCurrency__c
                                                              = pCurrency.ID,c2g__GeneralLedgerAccount__c = cGLA.ID ,c2g__AccountName__c = 'Bank Account 2' ,c2g__ReportingCode__c = 'GB2',  c2g__AccountNumber__c = '80775673355' , c2g__BankName__c = 'Global Bank Pvt. Ltd. 2'));
            listOfBankAccount.add(new c2g__codaBankAccount__c(c2g__BankAccountCurrency__c = pCurrency.ID ,c2g__GeneralLedgerAccount__c = cGLA.ID ,c2g__AccountName__c = 'Bank Account 3' ,c2g__ReportingCode__c = 'GB3',  c2g__AccountNumber__c = '80775233355' , c2g__BankName__c = 'Global Bank Pvt. Ltd. 3'));
            insert listOfBankAccount;
            
            system.assertEquals(3, listOfBankAccount.size());
            
           
            //Bypassing Triggers so then test data can be created easily
            //Util.byPassAllTriggers = true;
                     
            //Cash Entry
            c2g__codaCashEntry__c cashEntry = new c2g__codaCashEntry__c();
            cashEntry.c2g__status__c = 'In Progress';
            //cashEntry.c2g__Value__c = 15;
            cashEntry.c2g__BankAccount__c = listOfBankAccount[0].ID;
            //Update By Mahendra Swarnakar - L2 Aug Release
            //cashEntry.c2g__BANKACCOUNTVALUE__c = -24;
            insert cashEntry; 
            
            Test.startTest();
            Batch_CashEntryDiscarding batchExe = new Batch_CashEntryDiscarding();
            DataBase.executeBatch(batchExe); 
            Test.stopTest();   
            
        }
    }
    
}