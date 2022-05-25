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
*   Purpose         :   Test class for Batch_UpdateSalesInvoiceAsLatestActivity
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/31/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
public class Test_Batch_UpdateSalesInvoiceWithLatest {
    
    //Test the functionality UpdateSalesInvoice
    static testmethod void test_UpdateSalesInvoice(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
        System.runAs(user1) {
            
            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            //Query for our currency from our setup data
            c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c = :testCompany.Id];
            
            //Grab the General Ledger Account created
            c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];
            
            //Grab the Dimension 1 record from our Test Data Setup
            c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];
            
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            
            //Bypassing the triggers.
            Util.ByPassAllTriggers = true; 
            insert salesInvoice;
            util.ByPassAllTriggers = false;
            
            Task t = TestUtilities.createTask(false,salesInvoice.Id);
            t.Grade__c = 'A+';
            t.CallDisposition = 'Pass';
            t.Status__c = 'Hold';
            t.Next_Steps__c = 'Nothing';
            t.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            //Bypassing the triggers.
            Util.ByPassAllTriggers = true; 
            insert t;
            util.ByPassAllTriggers = false;
            
            Task t2 = TestUtilities.createTask(false,salesInvoice.Id);
            t2.Grade__c = 'B+';
            t2.CallDisposition = 'Pass';
            t2.Status__c = 'Hold';
            t2.Next_Steps__c = 'Nothing';
            t2.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            //Bypassing the triggers.
            Util.ByPassAllTriggers = true; 
            insert t2;
            util.ByPassAllTriggers = false;
            
            //Start our Test
            Test.startTest();
            
            //Run our Batch
            Batch_UpdateSalesInvoiceWithLatestTask testBatch = new Batch_UpdateSalesInvoiceWithLatestTask();
            Database.executeBatch(testBatch);
            
            //Stop our Test
            Test.stopTest();
            
            c2g__codaInvoice__c updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice.Id LIMIT 1]; 
            
            /*System.assertEquals(t2.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t2.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t2.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t2.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t2.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t2.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c); */
        }
    }
    

}