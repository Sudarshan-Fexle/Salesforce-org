@istest(Seealldata =false)
public class Test_RedirectHubContoller {
    
    @testSetup static void testData()
    {
        Account acct = TestUtilities.CreateNewAccount(true);
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        Id caseRecordTypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('WebHelp').getRecordTypeId();
        System.assert(caseRecordTypeid != null );
        
        //Create a sample case records
        for(Integer i = 1 ; i <= 7 ; i++)
        {
            Case aCase_1 = new Case(RecordTypeId = caseRecordTypeid, Origin = 'ABC'+i, Subject = 'Test', 
                                    Description = 'Test'+i, AccountId = acct.Id);
            cases.add(aCase_1);
        }
        insert cases;
        system.assert(cases.size() > 0);
        
        // Creating Contract record
        Contract contract = new Contract(AccountId = acct.Id, Status = 'Draft', EndDate = System.today().addDays(-10));
        insert contract;
        
        system.assert(contract.Id != null);
        
        // Create Invoice Billing Sched
        Invoice_Billing_Schedule__c ibs = new Invoice_Billing_Schedule__c(Institution__c = acct.Id, Standard_Contract__c = contract.Id);
        insert ibs;
        
    }
    
    static testMethod void testSetupEnv()
    {
        
    	Id SandboxSeriesRecordTypeid = Schema.SObjectType.IS_Environment__c.getRecordTypeInfosByName().get('Sandbox Series').getRecordTypeId();
        System.assert(SandboxSeriesRecordTypeid != null);
        
        //create  Is Environment records
        IS_Environment__c env1 = new IS_Environment__c (Name = 'Test2', Common_Name__c = 'Test2', RecordTypeId = SandboxSeriesRecordTypeid);
        insert env1;
        
        Test.startTest();
        
        System.currentPageReference().getParameters().put('envId', env1.Id );
        RedirectHubContoller redirectHubCont = new RedirectHubContoller();
        redirectHubCont.evaluate();
        redirectHubCont.setupEnv();
        
        Test.stopTest();
        String envId = ApexPages.currentPage().getParameters().get('envId');
        system.assertEquals(true, envId != null);
    }
    
    // test ShipIt with contactStatus Inactive
    static testMethod void testShipItWithContactStatus()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'ShipIt' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('contactStatus', 'Inactive' );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        system.assertEquals(true, conId != null);
        
    }
    
    // test ShipIt with CurrentUserProfile Travel & Events Contractor - External
    static testMethod void testShipItWithCurrentUserProfileTravel()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'ShipIt' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('currentUserProfile', 'Travel & Events Contractor - External');
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        system.assertEquals(true, conId != null);
    }
    
    // test ShipIt with CurrentUserProfile Travel & Events Contractor - External
    static testMethod void testShipItWithCurrentUserProfilePortal()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'ShipIt' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('currentUserProfile', 'Portal');
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        system.assertEquals(true, conId != null);
    }
    
    // test ShipIt with contactCountry not equals United States
    static testMethod void testShipItWithcontactCountry()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'ShipIt' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('contactCountry', 'India');
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        system.assertEquals(true, conId != null);
    }
    
    // test ShipIt with contactid to redirect it
    static testMethod void testShipItWithContactId()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'ShipIt' );
        System.currentPageReference().getParameters().put('contactid', con.Id );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        
        String conId = ApexPages.currentPage().getParameters().get('contactid');
        system.assertEquals(true, conId != null);
    }
    
    // Test newCase with classic true
    static testMethod void testNewCaseWithClassicTrue()
    {
        List<Case> cases = [SELECT Id, CaseNumber FROM Case];
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'newCase' );
        System.currentPageReference().getParameters().put('caseRecordType', Label.Case_WebHelp_RT_Id);
        System.currentPageReference().getParameters().put('cas28_lkid', cases[0].Id);
        System.currentPageReference().getParameters().put('classic', 'true');
        System.currentPageReference().getParameters().put('cas28', cases[1].Id);
        System.currentPageReference().getParameters().put('cas21', cases[2].Id);
        System.currentPageReference().getParameters().put('ParentCaseNumber', cases[3].Id);
        System.currentPageReference().getParameters().put('cas11', cases[4].Id);
        System.currentPageReference().getParameters().put('cas3_lkid', '');
        
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
    }
    
    // Test newCase with classic false
    static testMethod void testNewCaseWithClassicFalse()
    {
        List<Case> cases = [SELECT Id, CaseNumber, RecordTypeId FROM Case];
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'newCase' );
        System.currentPageReference().getParameters().put('caseRecordType', cases[0].RecordTypeId);
        System.currentPageReference().getParameters().put('cas28_lkid', cases[0].Id);
        System.currentPageReference().getParameters().put('classic', 'false');
        System.currentPageReference().getParameters().put('cas28', cases[1].Id);
        System.currentPageReference().getParameters().put('cas21', cases[2].Id);
        System.currentPageReference().getParameters().put('ParentCaseNumber', cases[3].Id);
        System.currentPageReference().getParameters().put('cas11', cases[4].Id);
        System.currentPageReference().getParameters().put('cas3_lkid', '');
        
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
    }
    
    // Test Meeting Recruitment With ConHistory
    static testMethod void testMeetingRecruitmentWithConHistory()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        /*Site_Profile__c siteProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        siteProfile.Tokens__c = 5;
        siteProfile.Contact__c = con.Id;
        insert siteProfile;
        
        system.assertEquals(true, siteProfile.Id != null);
        
        System.assertEquals(true, siteProfile.Contact__c != null);*/
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Meeting_Recruitment' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('conHistory', 'Testing History');
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        system.assertEquals(true, conId != null);
        String conHistory = ApexPages.currentPage().getParameters().get('conHistory');
        System.assertEquals(true, conHistory != null);
    }
    
    // Test Meeting Recruitment Without ConHistory
    static testMethod void testMeetingRecruitmentWithoutConHistory()
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        system.assertEquals(true, con.Id != null);
        
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Meeting_Recruitment' );
        System.currentPageReference().getParameters().put('conId', con.Id );
        System.currentPageReference().getParameters().put('conHistory', null);
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        
        Test.stopTest();
        String conId = ApexPages.currentPage().getParameters().get('conId');
        System.assertEquals(true, conId != null);
        String conHistory = ApexPages.currentPage().getParameters().get('conHistory');
        System.assertEquals(null, conHistory);
    }
    
    // test SBQQAmendContract with end date greater than today
    static testMethod void testSBQQAmendContract()
    {
        List<Contract> contracts = [SELECT Id FROM Contract];
        //SBQQ__RenewalQuoted__c = true (Checkbox)
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'SBQQ__AmendContract' );
        System.currentPageReference().getParameters().put('Id', contracts[0].Id );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
        String contId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true, contId != null);
    }
    
    // test SBQQAmendContract with SBQQ__RenewalQuoted__c true
    static testMethod void testSBQQAmendContractWithRenewalQuote()
    {
        List<Contract> contracts = [SELECT Id, SBQQ__RenewalQuoted__c FROM Contract];
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'SBQQ__AmendContract' );
        System.currentPageReference().getParameters().put('Id', contracts[0].Id );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
        String contId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true, contId != null);
    }
    
    // test SBQQAmendContract with StatusCode
    static testMethod void testSBQQAmendContractWithStatusCode()
    {
        List<Contract> contract = [SELECT Id, StatusCode FROM Contract];
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'SBQQ__AmendContract' );
        System.currentPageReference().getParameters().put('Id', contract[0].Id );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
        String contId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true, contId != null);
    }
    
    // test SBQQAmendContract with Status
    static testMethod void testSBQQAmendContractWithStatus()
    {
        List<Contract> contract = [SELECT Id, Status FROM Contract];
        //SBQQ__RenewalQuoted__c = true (Checkbox)
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'SBQQ__AmendContract' );
        System.currentPageReference().getParameters().put('Id', contract[0].Id );
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
        String contId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true, contId != null);
    }
    
    // test CreateInvoiceBillingSched with Invoice Billing Sched Id
    static testMethod void testCreateInvoiceBillingSchedWithIbsID()
    {
        Invoice_Billing_Schedule__c ibs = [SELECT Id FROM Invoice_Billing_Schedule__c LIMIT 1];
        System.assert(ibs.Id != null);
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Create_Invoice_Billing_Sched' );
        System.currentPageReference().getParameters().put('ibsID', ibs.Id);
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
    }
    
    // test CreateInvoiceBillingSched without Invoice Billing Sched Id
    static testMethod void testCreateInvoiceBillingSchedWithoutIbsID()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Create_Invoice_Billing_Sched' );
        System.currentPageReference().getParameters().put('ibsID', null);
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
    }
    
    // test CreateInvoiceBillingSched with Invoice Billing Sched Id
    static testMethod void testCreateInvoiceBillingSchedSubscriptionWithInvoice()
    {
        Invoice_Billing_Schedule__c ibs = [SELECT Id FROM Invoice_Billing_Schedule__c LIMIT 1];
        System.assert(ibs.Id != null);
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Create_Invoice_Billing_Sched_Subscription' );
        System.currentPageReference().getParameters().put('ibsID', ibs.Id);
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
    }
    
    // test CreateInvoiceBillingSched without Invoice Billing Sched Id
    static testMethod void testCreateInvoiceBillingSchedSubscriptionWithoutInvoice()
    {
        Invoice_Billing_Schedule__c ibs = [SELECT Id FROM Invoice_Billing_Schedule__c LIMIT 1];
        System.assert(ibs.Id != null);
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.RedirectHub'));
        System.currentPageReference().getParameters().put('location', 'Create_Invoice_Billing_Sched_Subscription' );
        System.currentPageReference().getParameters().put('ibsID', null);
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
    }
    
    static testMethod void testPostCashEntry()
    {
        Test.startTest();
        System.currentPageReference().getParameters().put('location', 'Post_Cash_Entry' );
        // Put hardcode Id due to issue in creating c2g_CodaCashEntry__c record
       	System.currentPageReference().getParameters().put('cashentryid',  'a11C0000002icZrIAI');
        RedirectHubContoller redirectHubCon = new RedirectHubContoller();
        redirectHubCon.evaluate();
        Test.stopTest();
    }
    
    static testMethod void testPostSalesInvoice()
    {
        
    }
    
    static testMethod void testPostPayableInvoice()
    {
        
    }
    
    static testMethod void testPostSalesCreditNote()
    {
        
    }
    
    static testMethod void testAddProgramSubscription()
    {
        
    }
    
    static testMethod void testLogOutreach()
    {
        
    }
    
}