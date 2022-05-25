/**
    * Purpose		: Test class for PrintInvoiceController
    *
    * Create By		: Abhinav Sharma
    *
    * Created Date	: 03/04/2020
    *
    * Revision Log	: V_1.0 - Created - Abhinav Sharma
    *
    * Coverage		: V_1.0 - 
    *
**/
@isTest(seeAllData = false)
private class Test_PrintInvoiceController
{
    @testSetup static void setup() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Saweda';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
    }
    
    @isTest static void testSalesInvoiceValidateApproval() {
        
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        
        
        
        System.runAs(user1) {

            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            //Create our list needed for the tests
            List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();
            
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            
            //Create our second test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            
            c2g__codaInvoice__c salesInvoice3 = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                Content_Document_ID__c = '0692h000000JBucAAG',
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            salesInvoiceList.add(salesInvoice);
            salesInvoiceList.add(salesInvoice2);
            salesInvoiceList.add(salesInvoice3);
            insert salesInvoiceList;
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = salesInvoiceList[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            salesInvoiceList[0].Content_Document_ID__c = documents[0].Id;
            update salesInvoiceList;
            
            //Grab some real records to test for Custom Permission to be able to Post
            List<c2g__codaInvoice__c> salesInvoiceList3 = [SELECT Id, Name,c2g__PrintStatus__c,c2g__InvoiceDescription__c,Content_Document_ID__c FROM c2g__codaInvoice__c WHERE c2g__InvoiceDescription__c = 'Test List 1'];
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(salesInvoiceList3[0]); 
                PrintInvoiceController contrl = new PrintInvoiceController(sc); 
                contrl.downloadInvoice();
            }
            catch(Exception e){
                system.assertEquals('', e.getMessage());
            }
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(salesInvoiceList3[1]); 
                PrintInvoiceController contrl = new PrintInvoiceController(sc); 
                
            }
            catch(Exception e){
            	system.assertEquals('', e.getMessage());
            }
            
            List<c2g__codaInvoice__c> salesInvoiceList4 = [SELECT Id, Name,c2g__PrintStatus__c,c2g__InvoiceDescription__c,Content_Document_ID__c FROM c2g__codaInvoice__c WHERE c2g__InvoiceDescription__c = 'Test List 1'];
            system.assertEquals('Not Printed', salesInvoiceList4[0].c2g__PrintStatus__c);
        }
    }
}