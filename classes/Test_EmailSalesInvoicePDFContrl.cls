/**
    * Purpose		: Test class for GenerateInvoices
    *
    * Create By		: Abhinav Sharma
    *
    * Created Date	: 03/04/2020
    *
    * Revision Log	: V_1.0 - Created - Abhinav Sharma
    *
    * Coverage		: V_1.0 - 84%
    *
**/
@isTest(seeAllData = false)
private class Test_EmailSalesInvoicePDFContrl
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
        
        System.runAs(user1) {
            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
            
            EmailTemplate et  = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'testTemplate'; 
            et.DeveloperName = 'testTemplate' + System.now().getTime(); 
            et.TemplateType = 'text'; 
            et.FolderId = UserInfo.getUserId(); 
            et.Body = ''; 
            
            insert et; 
        
            List<Contact> contact = new List<Contact>();
            contact.add(new Contact(LastName = 'TestContact1', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            contact.add(new Contact(LastName = 'TestContact2', AccountId = testAcc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
            insert contact;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            //Create our list needed for the tests
            List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();
            
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(c2g__Account__c = testAcc.Id, c2g__DueDate__c = System.today(), c2g__InvoiceDate__c = System.Today(),
                                                                      c2g__InvoiceStatus__c = 'In Progress', c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 1',
                                                                      Invoice_Contact__c= contact[0].Id, Credit_Manager__c = user1.Id);
            
            //Create our second test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(c2g__Account__c = testAcc.Id,c2g__DueDate__c = System.today(),c2g__InvoiceDate__c = System.Today(),c2g__InvoiceStatus__c = 'In Progress',
                                                                        c2g__DerivePeriod__c = True, c2g__InvoiceDescription__c = 'Test List 2');
            
            salesInvoiceList.add(salesInvoice);
            salesInvoiceList.add(salesInvoice2);
            insert salesInvoiceList;
            
            
            ContentVersion contentVersion = new ContentVersion(Title = 'Penguins',PathOnClient = 'Penguins.jpg',VersionData = Blob.valueOf('Test Content'),
                                                               IsMajorVersion = true);
            
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
        }
        
    }
    
    @isTest static void testSalesInvoicePositiveUseCase() {
        
       
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
       
             Test.startTest();
            //Grab some real records to test for Custom Permission to be able to Post
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name,Content_Document_ID__c,c2g__InvoiceDescription__c,Credit_Manager__c,Invoice_Contact__c,Invoice_Contact__r.Email FROM c2g__codaInvoice__c where c2g__InvoiceDescription__c = 'Test List 1' Limit 1];
            system.assertEquals(1, salesInvoiceList.size());
          
            List<EmailTemplate> temp = [Select Id From Emailtemplate Limit 1];
            system.assertEquals(1, temp.size());
        
            ApexPages.StandardController stdController = new ApexPages.StandardController(salesInvoiceList[0]);
            EmailSalesInvoicePDFController contrl = new EmailSalesInvoicePDFController(stdController); 
            contrl.sendInvoiceEmail();
            Test.stopTest();
        
    }
    
    @isTest static void testEmailSalesInvoicesUseCase() {
        
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        System.runAs(user1) {
             Test.startTest();
            //Grab some real records to test for Custom Permission to be able to Post
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name,Content_Document_ID__c,c2g__InvoiceDescription__c,Credit_Manager__c,Invoice_Contact__c FROM c2g__codaInvoice__c];

            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(salesInvoiceList);
            EmailSalesInvoicesPDFController contrl = new EmailSalesInvoicesPDFController(stdController); 
            contrl.backToListView();
            test.stopTest();
        }
    }
    
     @isTest static void testEmailSalesInvoicesNegativeUseCase() {
        
        //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        System.runAs(user1) {
            test.startTest();
            //Grab some real records to test for Custom Permission to be able to Post
            List<c2g__codaInvoice__c> salesInvoiceList = [SELECT Id, Name,Content_Document_ID__c,c2g__InvoiceDescription__c,Invoice_Contact__c FROM c2g__codaInvoice__c];

            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(salesInvoiceList);
            EmailSalesInvoicesPDFController contrl = new EmailSalesInvoicesPDFController(stdController); 
            contrl.backToListView();
             test.stopTest();
        }
    }
}