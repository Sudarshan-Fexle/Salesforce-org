/**
 *  Purpose         :   This class is helper class for trigger on Opportunity object.
 *              
 *  Create By       :   Mahendra Swarnkar
 *  
 *  Created Date    :   05/25/2020
 *  
 *  Current Version :   V1.0 
 *  
 *  Revision Log    :   V1.0 - Created  
 *                      V1.1 - Modified By - Mahendra Swarnkar - 02/01/2021 - CR-20201109-14679 - BSP Clone Enhancement
 *  
**/
@isTest
private class Test_BillingSchedulePeriodTriggerHelper {
	
    @TestSetup
    static void setup(){
        Test.startTest();
        
        //Bypass Dupeblocker
        Util.IsTest(true);

        //Bypass Triggers
        Util.BypassAllTriggers = true;

        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user3 = testUtilities.CreateNewUser(p, true);
        user3.LastName = 'Saweda';
        update user3;

        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User3.Id);
        
        
       //Grab the User for running the Test
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];

        //Grab our user from Test Utilities Class
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'O Driscoll'];

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
            
		insert salesInvoice;
            
        List<Billing_Schedule_Period__c> listOfBSPtoInsert = new List<Billing_Schedule_Period__c>();
        listOfBSPtoInsert.add(new Billing_Schedule_Period__c(Name = 'Billing Schedule Period 1' , Sales_Invoice__c = salesInvoice.Id, Installment__c = 1));
        listOfBSPtoInsert.add(new Billing_Schedule_Period__c(Name = 'Billing Schedule Period 2' , Sales_Invoice__c = null, Installment__c = 2));
        insert listOfBSPtoInsert;
        system.debug(listOfBSPtoInsert);
        
        system.assertEquals(2, listOfBSPtoInsert.size());
        
        List<Billing_Schedule_Period__c> ss = [SELECT Name From Billing_Schedule_Period__c LIMIT 10];
        system.debug('Size T0 Check:: ' + ss.size());
        system.debug(ss);
            
        List<Billing_Schedule_Line__c> listOfbSLToInsert = new List<Billing_Schedule_Line__c>();
        listOfbSLToInsert.add(new Billing_Schedule_Line__c(Billing_Schedule_Period__c = listOfBSPtoInsert[1].Id));
        insert listOfbSLToInsert;
        
        system.assertEquals(1, listOfbSLToInsert.size());
        
        
    }
        Test.stopTest();
    }
    
    @isTest
    static void validateBSPsInstallment(){
        Test.startTest();
        List<Billing_Schedule_Period__c> bsp = [SELECT Name, Installment__c From Billing_Schedule_Period__c LIMIT 10];
               
        bsp[0].Installment__c = 2;

        try{
            update bsP[0];
        }
        catch(Exception  e){
            System.assertEquals(false, e.getMessage().contains('Installment # Of newly created or Updated BSP already exist on associated BSH.')); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void validateBSPsTest(){
        Test.startTest();
	List<Billing_Schedule_Period__c> ss = [SELECT Name From Billing_Schedule_Period__c Where Sales_Invoice__c != null LIMIT 10];
        
        
        Billing_Schedule_Period__c bsP = [SELECT Id, Name, Sales_Invoice__c From Billing_Schedule_Period__c  Where Sales_Invoice__c != null LIMIT 1];
        
        try{
            delete bsP;
        }
        catch(DMLException  e){
            System.assert(e.getDmlMessage(0).indexOf('You can not delete ' + bsP.Name) > -1); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void validateBSPsTest1(){
        Test.startTest();
	List<Billing_Schedule_Period__c> ss = [SELECT Name From Billing_Schedule_Period__c Where Sales_Invoice__c != null LIMIT 10];
        
        
        Billing_Schedule_Period__c bsP = [SELECT Id, Name, Sales_Invoice__c From Billing_Schedule_Period__c  Where Sales_Invoice__c != null LIMIT 1];
        
        try{
            delete bsP;
        }
        catch(DMLException  e){
            System.assert(e.getDmlMessage(0).indexOf('You can not delete ' + bsP.Name) > -1); 
        }
        Test.stopTest();
    }
    
    /*
    @isTest
    static void validateDeleteRelatedBSL(){
        Test.startTest();
        Billing_Schedule_Period__c bsP = [SELECT Id, Name From Billing_Schedule_Period__c LIMIT 1];
        delete bsP;
        
        List<Billing_Schedule_Line__c> listOfBSL = [SELECT Name FROM Billing_Schedule_Line__c Where Billing_Schedule_Period__c =: bsP.ID LIMIT 1];
        
        system.assertEquals(0, listOfBSL.size());
        
        Test.stopTest();
   		 }
    */
    
    /**
    * 
    *  @description   :   Added method to test cases of updateBSPonClone
    *
    *  @args          :   List<Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
    * 
    **/
    @isTest
    static void test_updateBSPonClone(){
        Test.startTest();
	List<Billing_Schedule_Period__c> billingSchPeriods = [SELECT Name, Sales_Invoice__c, Actual_Invoice_Sent_Date__c,
                                                              Billing_Posted_Date__c, Billing_Date_Override__c
                                                              From Billing_Schedule_Period__c 
                                                              Where Sales_Invoice__c != null LIMIT 10];
	//update BSP with fields value
        billingSchPeriods[0].Billing_Date_Override__c = System.today();
        billingSchPeriods[0].Billing_Posted_Date__c = System.today();
        billingSchPeriods[0].Actual_Invoice_Sent_Date__c = System.today();
        
        Update billingSchPeriods[0];
        
        //Assertion on result
        System.assertEquals(System.today(), billingSchPeriods[0].Billing_Date_Override__c);
        System.assertEquals(System.today(), billingSchPeriods[0].Billing_Posted_Date__c);
        System.assertEquals(System.today(), billingSchPeriods[0].Actual_Invoice_Sent_Date__c);
        
        //Insert clone BSP
        Billing_Schedule_Period__c cloneBSP = billingSchPeriods[0].clone(false,false,false,false);
        Insert cloneBSP;
        
        Billing_Schedule_Period__c clonedBSP = [Select Id, Billing_Date_Override__c, Billing_Posted_Date__c, Actual_Invoice_Sent_Date__c
                                               	FROM Billing_Schedule_Period__c WHERE Id =: cloneBSP.Id limit 1];
        //Assertion on result
        System.assertEquals(true, cloneBSP.ISCLONE());
        System.assertEquals(null, clonedBSP.Billing_Date_Override__c);
        System.assertEquals(null, clonedBSP.Billing_Posted_Date__c);
        System.assertEquals(null, clonedBSP.Actual_Invoice_Sent_Date__c);
        
        Test.stopTest();
    }
    
    /**
    * 
    *  @description   :   Added method to test cases of cloneBSLonBSPclone
    *
    *  @args          :   List<Billing_Schedule_Period__c>
    *
    *  @return        :   void
    *
    *  @revision Log  :   V1.0 - Created - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
    * 
    **/
    @isTest
    static void test_cloneBSLonBSPclone(){
        Test.startTest();
		List<Billing_Schedule_Period__c> billingSchPeriods = [SELECT Id, Name, Billing_Date_Override__c
                                                              From Billing_Schedule_Period__c 
                                                              Where Sales_Invoice__c != null LIMIT 10];
		//update BSP with fields value
        billingSchPeriods[0].Billing_Date_Override__c = System.today();
        
        Update billingSchPeriods[0];
                
        //Assertion on result
        System.assertEquals(System.today(), billingSchPeriods[0].Billing_Date_Override__c);
        
        List<Billing_Schedule_Line__c> billingScheduleLines = new List<Billing_Schedule_Line__c>();
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Period__c = billingSchPeriods[0].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Period__c = billingSchPeriods[0].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        insert billingScheduleLines;

        //Insert clone BSP
        Billing_Schedule_Period__c cloneBSP = billingSchPeriods[0].clone(false,false,false,false);
        Insert cloneBSP;
        
        
        Billing_Schedule_Period__c clonedBSP = [Select Id, Billing_Date_Override__c, Billing_Posted_Date__c, Actual_Invoice_Sent_Date__c
                                               	FROM Billing_Schedule_Period__c WHERE Id =: cloneBSP.Id limit 1];
        
        //Assertion on result
        System.assertEquals(true, cloneBSP.ISCLONE());
        System.assertEquals(null, clonedBSP.Billing_Date_Override__c);
        System.assertEquals(2, [Select Id From Billing_Schedule_Line__c Where Billing_Schedule_Period__c =: clonedBSP.Id].size());
        Test.stopTest();
    }
    
}