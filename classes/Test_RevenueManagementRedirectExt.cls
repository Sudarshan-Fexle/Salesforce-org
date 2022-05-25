/**
*	Purpose            :    Test class for RevenueManagementRedirectExt 
*
*	Created By         :    Chirag Soni
*
*	Current Version    :    V1.0
*
*	Created Date       :    10/14/2021
*
*	Revision Log       :    V1.0 - Created - Chirag Soni - CR-20211012-15511 - 10/14/2021 - increase code coverage
*
**/
@isTest(seeAllData = false)
private class  Test_RevenueManagementRedirectExt
{
    @testSetup 
    static void dataSetup()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;
        
        //insert account
        Account account = testUtilities.CreateNewAccount(true);
        
        //insert contact
        Contact contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        //insert
        insert contact;
        //insert Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        list<Contract__c> contracts = new list<Contract__c>();
        //create contract  
        contracts.add(new Contract__c(
            Payer_Account__c = account.id,
            Program__c = prog.id,
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2011',
            Record_Source__c = 'Shadow',
            Main_Contact__c = contact.id,
            Invoice_Contact__c = contact.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
        ));
        insert contracts;
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, 
                                                    SBQQ__ListPrice__c = 0,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, GAAP_Amount__c = 1000, Program_Subscription__c = subscriptions[0].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0, Program_Subscription__c = subscriptions[0].Id));
        
        insert aBCRevenues;
        
        Util.byPassAllTriggers = false;
    } 
    
    //Create By -  Chirag Soni - CR-20211012-15511 - 10/14/2021 - test method to RevenueManagementRedirectExt constructor
    static testMethod void testRevenueManagementRedirectExt()
    {
        //Query to fetch Contract ABC  Records
         List<ABC_Revenue__c> aBCRevenues = [Select Id From ABC_Revenue__c Limit 1];
        
        Test.startTest();
        
        //Use Case 1 -  setting standard controller
        ApexPages.StandardController controller = new ApexPages.StandardController(aBCRevenues[0]);

        //asserts
        System.assert(controller!=null);
    	
        //Use Case 2  -  fetch contract from controller
        RevenueManagementRedirectExt revenueManagement = new RevenueManagementRedirectExt(controller);
        //assert 
        System.assertEquals(aBCRevenues[0].Id, revenueManagement.revenue.Id);
        
        //setting standard set controller
        ApexPages.standardSetController controller1 = new ApexPages.standardSetController(aBCRevenues);
        controller1.setSelected(aBCRevenues);
        //asserts
        System.assert(controller1!=null);
    	RevenueManagementRedirectExt revenueManagement1 = new RevenueManagementRedirectExt(controller1);
        
        //Use Case 3  -  test redirectFromParent
        Pagereference page = revenueManagement.redirectFromParent();
        System.assertEquals(true, page.getRedirect());
        
        //Use case 4  -  test redirect 
        //Use Case 4.1
        page = revenueManagement.redirect();
       	System.assertEquals(true, page.getRedirect());
        
        //update aBCRevenues 
        //Bypass flag
        Util.byPassAllTriggers = true;
        
        aBCRevenues[0].Program_Subscription__c = null;
        update aBCRevenues;
        //Use Case 4.2
        revenueManagement = new RevenueManagementRedirectExt(controller);
        
        Util.byPassAllTriggers = false;
        page = revenueManagement.redirect();
       	System.assertEquals(true, page.getRedirect());
       
        Test.stopTest();
    }  
}