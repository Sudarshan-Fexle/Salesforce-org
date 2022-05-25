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
 //V1.1 - Modified By - Deepak Kumar - 7/05/2017 -  Q2C Redesign - Beta Release - Changes
@isTest
private class Test_CreateLineItemSchedule { 

    static testMethod void TestCreateLineItemSchedule() {  
        
        Util.IsTest(true);
        Util.byPassAllTriggers = True;
        
        Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert a;
        
        Contact con = new Contact(AccountId = a.Id, FirstName = 'Drew', LastName = 'Test', Email = 'Test'+Math.random()+'@eab.com', 
									Title = 'Test', Phone = '614-555-8855');
        insert con;

        Program__c p = new Program__c(Name = 'TestProgram');
        insert p;
        
        Util.byPassAllTriggers = False;
 
        Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = a.Id);
        insert ibs;

        Contract__c c = new Contract__c(Name = 'DAF Test', Payer_Account__c = a.Id, Status__c = 'ATL', 
        Negotiated_Amount__c = 1000.0, Type__c = 'NBB', Start__c = date.today(), End__c = date.today(), Year__c = '2012', Join_Date__c = date.today(), 
        Main_Contact__c = con.Id, Invoice_Contact__c = con.Id, Program__c = p.Id);
        insert c;

        List<Product2> prod = [SELECT Id, Name FROM Product2 Limit 1]; 
        
        //Test starts from here
        test.startTest();
        
        PageReference pageRef = Page.CreateLineItemSchedule;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', c.Id);

        CreateLineItemSchedule controller = new CreateLineItemSchedule();

        c.Invoice_Billing_Schedule__c = ibs.Id;
        update c;
        
        Line_Item_Schedule__c lis = new Line_Item_Schedule__c(Contract__c = c.Id, Invoice_Billing_Schedule_del__c = ibs.Id, Type__c = 'Test', Invoice_Date__c = date.today(), Amount__c = 500);
        insert lis;
        CreateLineItemSchedule controller2 = new CreateLineItemSchedule();

        c.Years_in_Term__c = 2;
        update c;       
        /*CreateLineItemSchedule controller3 = new CreateLineItemSchedule();

        c.Invoicing_Arrangement__c = 'Monthly';
        update c;       
        CreateLineItemSchedule controller4 = new CreateLineItemSchedule();

        delete lis;
        CreateLineItemSchedule controller5 = new CreateLineItemSchedule();
        controller5.c.Initial_Invoice_Date__c = date.newinstance(2012, 3, 30);
        controller5.DoIt();

        List<Line_Item_Schedule__c> lisret = [select Id from Line_Item_Schedule__c where Contract__c = :c.Id];
        delete lisret;
        controller5.c.Initial_Invoice_Date__c = date.newinstance(2012, 3, 15);
        controller5.DoIt();

        controller5.Cancel();*/
        test.stopTest();
    }
    
    //Added by Ajit Surana - 04/21/2014 - CR-20140205-4459
    //Test method to Auto-generate line items based on annual amounts
    static testMethod void test_autoGenerateLineItems() {
        
        //Bypass the trigger 
        Util.IsTest(true);
        Util.byPassAllTriggers = True;
        
        //Insert test account record
        Account testAccount = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert testAccount;
        
        //Insert test contact record
        Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'User', LastName = 'Test', 
		Email = 'Test'+Math.random()+'@eab.com', 
		Title = 'Test', Phone = '614-555-8855');
        insert testContact;
        
        //Insert test program record
        Program__c testProgram = new Program__c(Name = 'TestProgram');
        insert testProgram;
        
        //Insert Invoice Billing Schedule record
        Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = testAccount.Id);
        insert ibs;
        
        //Insert Contract ABC record
        Contract__c c = new Contract__c(Name = 'Test Contract', Payer_Account__c = testAccount.Id, Status__c = 'ATL', Negotiated_Amount__c = 150000.00, Type__c = 'NBB', 
                                        Start__c = date.today(), End__c = date.today(), Year__c = '2014', Join_Date__c = date.today(), Exchange_Rate__c = 1,
                                        Main_Contact__c = testContact.Id, Invoice_Contact__c = testContact.Id, Program__c = testProgram.Id, 
                                        Invoicing_Arrangement__c = 'quarterly', Years_in_Term__c = 5, Invoice_Billing_Schedule__c = ibs.Id, Y1_Annual_Fee__c = null,
                                        Y2_Annual_Fee__c = null, Y3_Annual_Fee__c = null, Y4_Annual_Fee__c = null , Line_Item_Schedule_Total__c = 0);
        insert c;
        
        Util.byPassAllTriggers = false;
        
        //Test starts from here
        test.startTest();
        
        //Set the page reference
        PageReference pageRef = Page.CreateLineItemSchedule;
        Test.setCurrentPage(pageRef);
        
        //Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('cid', c.Id);
        
        //Instantiate the controller
        CreateLineItemSchedule controller = new CreateLineItemSchedule();
        controller.DoIt();
        
        //Query all Line Items Schedule records associated with this Test Contract record when only Negotiated Amount is populated 
        List<Line_Item_Schedule__c> lisList = [SELECT ID, Invoice_Billing_Schedule_del__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE 
                                                Contract__c =: c.Id]; 
        
        System.debug('lisList:::::::::'+ lisList);
        
        //Assert for results
        System.assertEquals(20, lisList.size());
        System.assertEquals(7500, lisList[0].Invoice_Amount__c);
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        delete lisList;
        
        //Update Contract ABC annual amount fee values
        c.Y1_Annual_Fee__c = 60000;
        c.Y2_Annual_Fee__c = 40000;
        c.Y3_Annual_Fee__c = 20000;
        update c;
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        controller.DoIt();
        
        //Query all Line Items Schedule records associated with this Test Contract record when Annual Amount is populated 
        lisList = [SELECT ID, Invoice_Billing_Schedule_del__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE 
                                                Contract__c =: c.Id]; 
        
        //Assert for results
        System.assertEquals(20, lisList.size());
        System.assertEquals(15000, lisList[0].Invoice_Amount__c);
        System.assertEquals(15000, lisList[1].Invoice_Amount__c);
        System.assertEquals(15000, lisList[2].Invoice_Amount__c);
        System.assertEquals(15000, lisList[3].Invoice_Amount__c);
        System.assertEquals(10000, lisList[4].Invoice_Amount__c);
        System.assertEquals(10000, lisList[5].Invoice_Amount__c);
        System.assertEquals(10000, lisList[6].Invoice_Amount__c);
        System.assertEquals(10000, lisList[7].Invoice_Amount__c);
        System.assertEquals(5000, lisList[8].Invoice_Amount__c);
        System.assertEquals(5000, lisList[9].Invoice_Amount__c);
        System.assertEquals(5000, lisList[10].Invoice_Amount__c);
        System.assertEquals(5000, lisList[11].Invoice_Amount__c);
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        
        //Delete Line Items Schedule list
        delete lisList;
        
        //Update Contract ABC "Invoice Arrangement" and "Years In Term values"
        c.Invoicing_Arrangement__c = 'monthly';
        c.Years_in_Term__c = 2;
        c.Y2_Annual_Fee__c = 120000;
        update c;
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        controller.DoIt();
        
        //Query all Line Items Schedule records associated with this Test Contract record when Annual Amount is populated 
        lisList = [SELECT ID, Invoice_Billing_Schedule_del__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE 
                                                Contract__c =: c.Id]; 
        
        //Assert for results
        System.assertEquals(24, lisList.size());
        System.assertEquals(5000, lisList[0].Invoice_Amount__c);
        System.assertEquals(5000, lisList[1].Invoice_Amount__c);
        System.assertEquals(5000, lisList[2].Invoice_Amount__c);
        System.assertEquals(5000, lisList[3].Invoice_Amount__c);
        System.assertEquals(5000, lisList[4].Invoice_Amount__c);
        System.assertEquals(5000, lisList[5].Invoice_Amount__c);
        System.assertEquals(5000, lisList[6].Invoice_Amount__c);
        System.assertEquals(5000, lisList[7].Invoice_Amount__c);
        System.assertEquals(5000, lisList[8].Invoice_Amount__c);
        System.assertEquals(5000, lisList[9].Invoice_Amount__c);
        System.assertEquals(5000, lisList[10].Invoice_Amount__c);
        System.assertEquals(5000, lisList[11].Invoice_Amount__c);
        
        System.assertEquals(10000, lisList[12].Invoice_Amount__c);
        System.assertEquals(10000, lisList[13].Invoice_Amount__c);
        System.assertEquals(10000, lisList[14].Invoice_Amount__c);
        System.assertEquals(10000, lisList[15].Invoice_Amount__c);
        System.assertEquals(10000, lisList[16].Invoice_Amount__c);
        System.assertEquals(10000, lisList[17].Invoice_Amount__c);
        System.assertEquals(10000, lisList[18].Invoice_Amount__c);
        System.assertEquals(10000, lisList[19].Invoice_Amount__c);
        System.assertEquals(10000, lisList[20].Invoice_Amount__c);
        System.assertEquals(10000, lisList[21].Invoice_Amount__c);
        System.assertEquals(10000, lisList[22].Invoice_Amount__c);
        System.assertEquals(10000, lisList[23].Invoice_Amount__c);
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        
        //Delete Line Items Schedule list
        delete lisList;
        
        //Test stops here
        test.stopTest();
        
        //Update Contract ABC "Invoice Arrangement" and "Years In Term values"
        c.Invoicing_Arrangement__c = 'semi-annual';
        c.Years_in_Term__c = 2;
        update c;
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        controller.DoIt();
        
        //Query all Line Items Schedule records associated with this Test Contract record when Annual Amount is populated 
        lisList = [SELECT ID, Invoice_Billing_Schedule_del__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE 
                                                Contract__c =: c.Id]; 
        
        //Assert for results
        System.assertEquals(4, lisList.size());
        System.assertEquals(30000, lisList[0].Invoice_Amount__c);
        System.assertEquals(30000, lisList[1].Invoice_Amount__c);
        System.assertEquals(60000, lisList[2].Invoice_Amount__c);
        System.assertEquals(60000, lisList[3].Invoice_Amount__c);
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        
        //Delete Line Items Schedule list
        delete lisList;
        
        //Update Contract ABC "Invoice Arrangement" and "Years In Term values"
        c.Invoicing_Arrangement__c = 'annual';
        c.Years_in_Term__c = 2;
        update c;
        
        //Instantiate the controller
        controller = new CreateLineItemSchedule();
        controller.DoIt();
        
        //Query all Line Items Schedule records associated with this Test Contract record when Annual Amount is populated 
        lisList = [SELECT ID, Invoice_Billing_Schedule_del__c, Invoice_Amount__c FROM Line_Item_Schedule__c WHERE 
                                                Contract__c =: c.Id]; 
        
        //Assert for results
        System.assertEquals(2, lisList.size());  
        System.assertEquals(60000, lisList[0].Invoice_Amount__c);
        System.assertEquals(120000, lisList[1].Invoice_Amount__c);
        
        //Check for the assert
        System.assertNotEquals(null, controller.Cancel());  
    }
}