/*
    Purpose:	The Test class for BillableMilestoneController
    				   DeleteLISOnMilestoneDelete trigger
				   UpdateLISOnBillingEventRelease trigger
				   ValidateLISDeletion trigger
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    V1.0- 8/6/2015
                V1.1 - Updated By - Abhinav Sharma - CR-20170508-10917 - Tagging Template on Billable Milestone creation on a PSA Project (05/12/2017)
                V1.2 - Updated By - MAhendra Swarnkar - Run All Test - 06-12-12017- Release Rev Rec Phase 2 - Applied the check for Bypass all triggers.
		V1.3 - Modified By - Neha sharma - CR-20201110-14683
                V1.4 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
*/
@isTest(SeeAllData=true)
private class BillableMilestoneControllerTest {
    
    public static testMethod void testMilestoneCreation() {
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);

        pse__Proj__c project = createProject(acc, region, contractABC);
        
        //Bypass All Triggers
        Util.BypassAllTriggers = False;
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        BillableMilestoneController milestoneController = new BillableMilestoneController(stdController);

        // Should be five messages stating that no LISs were found.
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertEquals(5, pageMessages.size());

        List<Line_Item_Schedule__c> liSchedules = new List<Line_Item_Schedule__c>();
        Line_Item_Schedule__c liSchedule1 = createLineItemSchedule(contractABC, ibSchedule, 'Travel');
        liSchedules.add(liSchedule1);
        insert liSchedules;

        milestoneController = new BillableMilestoneController(stdController);
        System.assertEquals(1, milestoneController.lisWrappers.size());
        milestoneController.createMilestones();

        milestoneController.lisWrappers.get(0).isSelected = true;
        milestoneController.createMilestones();

        milestoneController.cancel();

        Test.stopTest();
    }
    
    public static testMethod void testMilestoneDeletion() {
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);

        pse__Proj__c project = createProject(acc, region, contractABC);

        List<Line_Item_Schedule__c> liSchedules = new List<Line_Item_Schedule__c>();
        Line_Item_Schedule__c liSchedule1 = createLineItemSchedule(contractABC, ibSchedule, 'Risk Travel');
        liSchedules.add(liSchedule1);
        insert liSchedules;
        
        //Bypass All Triggers
        Util.BypassAllTriggers = False;
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        BillableMilestoneController milestoneController = new BillableMilestoneController(stdController);
        System.assertEquals(1, milestoneController.lisWrappers.size());

        milestoneController.lisWrappers.get(0).isSelected = true;
        milestoneController.createMilestones();

        List<pse__Milestone__c> milestones = [
            select Id
            from pse__Milestone__c
            where pse__Project__c = :project.Id
        ];

        System.assertEquals(1, milestones.size());
        pse__Milestone__c milestone = milestones.get(0);

        //pse__Billing_Event__c be = createBE(project);
        //pse__Billing_Event_Item__c bei = createBEI(be, milestone);
        //be.pse__Is_Released__c = true;
        //update be;

        delete milestone;

        List<Line_Item_Schedule__c> lises = [
            select Id
            from Line_Item_Schedule__c
            where Id = :liSchedule1.Id
        ];

        System.assertEquals(0, lises.size());
        
        Test.stopTest();
    }
    
    public static testMethod void testLISDelete() {
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);

        pse__Proj__c project = createProject(acc, region, contractABC);

        List<Line_Item_Schedule__c> liSchedules = new List<Line_Item_Schedule__c>();
        Line_Item_Schedule__c liSchedule1 = createLineItemSchedule(contractABC, ibSchedule, 'Risk Travel');
        liSchedules.add(liSchedule1);
        insert liSchedules;
        
        //Bypass All Triggers
        Util.BypassAllTriggers = False;
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        BillableMilestoneController milestoneController = new BillableMilestoneController(stdController);
        System.assertEquals(1, milestoneController.lisWrappers.size());

        milestoneController.lisWrappers.get(0).isSelected = true;
        milestoneController.createMilestones();

        List<pse__Milestone__c> milestones = [
            select Id
            from pse__Milestone__c
            where pse__Project__c = :project.Id
        ];

        System.assertEquals(1, milestones.size());

        liSchedule1.Invoiced__c = true;
        update liSchedule1;

        try {
            // Should get an error about deleting an LIS that is invoiced
            delete liSchedule1;
            System.assertEquals(true, false);
        }
        catch (DmlException e) {
            milestones = [
                select Id
                from pse__Milestone__c
                where pse__Project__c = :project.Id
            ];

            System.assertEquals(1, milestones.size());
        }

        liSchedule1.Invoiced__c = false;
        update liSchedule1;
        try {
            // Should get an error about deleting an LIS that is associated with a billing milestone
            delete liSchedule1;
            System.assertEquals(true, false);
        }
        catch (DmlException e) {
            milestones = [
                select Id
                from pse__Milestone__c
                where pse__Project__c = :project.Id
            ];

            System.assertEquals(1, milestones.size());
        }

        Test.stopTest();
    }
    
    public static testMethod void testAdminFeeMALISDelete() {
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);

        pse__Proj__c project = createProject(acc, region, contractABC);

        Line_Item_Schedule__c liSchedule = createLineItemSchedule(contractABC, ibSchedule, 'Risk Travel');
        insert liSchedule;
        
        //Bypass All Triggers
        Util.BypassAllTriggers = False;
        
        pse__Miscellaneous_Adjustment__c adminFeeMA = createAdminFeeMA(project, liSchedule);

        Test.startTest();

        try {
            // Should get an error about deleting a Line Item Schedule that is associated with an Admin Fee MA
            delete liSchedule;
            System.assertEquals(true, false);
        }
        catch (DmlException e) {
            List<pse__Miscellaneous_Adjustment__c> mas = [
                select Id 
                from pse__Miscellaneous_Adjustment__c
                where pse__Project__c = :project.Id
            ];
            System.assertEquals(1, mas.size());
        }

        Test.stopTest();
    }
    
    public static testMethod void testMilestoneDelete() {
        
        //Bypass All Triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);
    
        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);

        pse__Proj__c project = createProject(acc, region, contractABC);

        List<Line_Item_Schedule__c> liSchedules = new List<Line_Item_Schedule__c>();
        Line_Item_Schedule__c liSchedule1 = createLineItemSchedule(contractABC, ibSchedule, 'Risk Travel');
        liSchedules.add(liSchedule1);
        insert liSchedules;
        
        //Bypass All Triggers
        Util.BypassAllTriggers = False;
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        BillableMilestoneController milestoneController = new BillableMilestoneController(stdController);
        System.assertEquals(1, milestoneController.lisWrappers.size());

        milestoneController.lisWrappers.get(0).isSelected = true;
        milestoneController.createMilestones();

        List<pse__Milestone__c> milestones = [
            select Id
            from pse__Milestone__c
            where pse__Project__c = :project.Id
        ];

        System.assertEquals(1, milestones.size());
        pse__Milestone__c milestone = milestones.get(0);

        liSchedule1.Invoiced__c = true;
        update liSchedule1;

        try {
            // Should get an error that a milestone associated with an invoiced LIS cannont be deleted
            delete milestone;
            System.assertEquals(true, false);
        }
        catch (DmlException e) {
            milestones = [
                select Id
                from pse__Milestone__c
                where pse__Project__c = :project.Id
            ];

            System.assertEquals(1, milestones.size());
        }

        liSchedule1.Invoiced__c = false;
        update liSchedule1;
        delete milestone;

        List<Line_Item_Schedule__c> lises = [
            select Id
            from Line_Item_Schedule__c
            where Id = :liSchedule1.Id
        ];

        System.assertEquals(0, lises.size());

        Test.stopTest();
    }
    
    private static Opportunity createOpportunity(Account acc) {
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta      
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            Main_Contact__c = cont.Id,
            StageName = 'Pending',
            CloseDate = Date.today(),
            //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
            //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
            Sales_Pursuit_Products__c  = 'APS'
        );
        
        insert opp;
        return opp;
    }

    private static Program__c createProgram() {
        Program__c program = new Program__c(
            Name = 'Test Program',
            Create_memberships__c = 'No',
            Status__c = 'Active'
        );

        insert program;
        return program;
    }

    private static Invoice_Billing_Schedule__c createInvoiceBillingSchedule(Account acc) {
        Invoice_Billing_Schedule__c ibSchedule = new Invoice_Billing_Schedule__c(
            Institution__c = acc.Id,
            Total_Negotiated_Amt__c = 1000.0
        );

        insert ibSchedule;
        return ibSchedule;
    }

    private static Line_Item_Schedule__c createLineItemSchedule(Contract__c contractABC, 
                                                                Invoice_Billing_Schedule__c ibSchedule, 
                                                                String type) {
        Line_Item_Schedule__c liSchedule = new Line_Item_Schedule__c(
            Contract__c = contractABC.Id,
            Invoice_Billing_Schedule_del__c = ibSchedule.Id,
            Type__c = type,
            Amount__c = 100.0,
            Invoice_Date__c = Date.today(),
            //Invoice_Comment__c = 'Comment',
            Invoiced__c = false
        );

        return liSchedule;
    }

    private static Contract__c createContractABC(Account acc, Opportunity opp, Program__c program, Contact contact, Invoice_Billing_Schedule__c ibSchedule) {
        Contract__c contractABC = new Contract__c(
            Name = 'Test Contract',
            Payer_Account__c = acc.Id,
            Source_Opportunity__c = opp.Id,
            Program__c = program.Id,
            Invoicing_Arrangement__c = 'Monthly',
            Project_Description__c = 'Project Description',
            Main_Contact__c = contact.Id,
            Invoice_Contact__c = contact.Id,
            Year__c = String.valueOf(Date.today().year()),
            Type__c = 'NBB',
            Start__c = Date.today(),
            Status__c = 'Pending',
            Term_Type__c = 'Fixed Term',
            Years_In_Term__c = 1,
            Invoice_Billing_Schedule__c = ibSchedule.Id
        );

        insert contractABC;
        return contractABC;
    }

    private static Contact createResource(pse__Region__c region) {
        
        List<Contact> cList = [select Id from Contact where pse__Salesforce_User__c=:UserInfo.getUserId()];
        for (Contact c : cList) {
            c.pse__Salesforce_User__c = null;
        }
        
        if (!cList.isEmpty()) {            
            update cList;
        }
        
       pse__Work_Calendar__c wc = new pse__Work_Calendar__c(Name='test');
        insert wc;
        
        Contact resource = new Contact(
            LastName = 'test',
            pse__Resource_Role__c = 'Consultant',
            pse__Salesforce_User__c = UserInfo.getUserId(),
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true, 
            pse__Work_Calendar__c = wc.Id,
            MailingCountry = 'USA',
            pse__Region__c = region.Id,
            Email = 'Test'+Math.random()+'@eab.com',
            Title = 'Test',
            Phone = '614-555-8855'
        );
        
        insert resource;
        return resource;
    }

    private static pse__Proj__c createProject(Account acc, pse__Region__c region, Contract__c contractABC) {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Allow_Timecards_Without_Assignment__c = true,
            pse__Allow_Expenses_Without_Assignment__c = true,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            Contract_ABC__c = contractABC.Id,
            pse__Account__c = acc.Id
        );
        
        insert project;
        return project;
    }
    
    private static pse__Time_Period__c createTimePeriod() {
        List<pse__Time_Period__c> timePeriods = [
            select Id, Name, pse__Start_Date__c, pse__End_Date__c 
            from pse__Time_Period__c 
            where Name = 'Perpetual'
        ];

        pse__Time_Period__c timePeriod = null;
        if (timePeriods.isEmpty()) {
            timePeriod = new pse__Time_Period__c(
                Name = 'Perpetual',
                pse__Start_Date__c = Date.newInstance(1990, 1, 1),
                pse__End_Date__c = Date.newInstance(2020, 1, 1)
            );

            insert timePeriod;
        }
        else {
            timePeriod = timePeriods.get(0);
        }

        return timePeriod;
    }

    private static pse__Billing_Event__c createBE(pse__Proj__c project) {
        pse__Time_Period__c timePeriod = createTimePeriod();

        pse__Billing_Event_Batch__c beb = new pse__Billing_Event_Batch__c(
            pse__Account__c = project.pse__Account__c,
            pse__Time_period__c = timePeriod.id
        );
        insert beb;

        List<c2g__codaCompany__c> companies = [SELECT Id FROM c2g__codaCompany__c];
        c2g__codaCompany__c company = null;
        if (!companies.isEmpty()) {
            company = companies.get(0);
        }

        pse__Billing_Event__c be = new pse__Billing_Event__c(
            pse__Billing_Event_Batch__c = beb.id,
            pse__Project__c = project.id,
            ffpsai__OwnerCompany__c = company == null ? null : company.Id,
            pse__Skip_Sync_Check__c = true
        );
        insert be;
        return be;
    }

    private static pse__Billing_Event_Item__c createBEI(pse__Billing_Event__c be, pse__Milestone__c milestone) {
        Product2 servicesProduct = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true
        );
        insert servicesProduct;

        pse__Billing_Event_Item__c bei = new pse__Billing_Event_Item__c(
            pse__Billing_Event_Batch__c = be.pse__Billing_Event_Batch__c,
            pse__Billing_Event__c = be.id,
            pse__Object_Id__c = milestone.id,
            pse__Milestone__c = milestone.id,
            pse__Project__c = be.pse__Project__c,
            pse__Category__c = 'Milestone',
            ffpsai__ServicesProduct__c = servicesProduct.Id
        );
        insert bei;
        return bei;
    }

    private static void createTransaction(pse__Milestone__c milestone, pse__Region__c region) {
        pse__Transaction__c trnsaction = new pse__Transaction__c(
            pse__Category__c = 'Billable External Hours',
            pse__Effective_Date__c = Date.today(),
            pse__isBilled__c = true,
            pse__Milestone__c = milestone.Id,
            pse__Project__c = milestone.pse__Project__c,
            pse__Region__c = region.Id,
            pse__Type__c = 'Milestone'
        );

        insert trnsaction;
    }

    private static c2g__codaInvoice__c createSalesInvoice(Account acc, 
                                                          pse__Billing_Event__c billingEvent, 
                                                          pse__Proj__c project, 
                                                          c2g__codaCompany__c company,
                                                          c2g__codaAccountingCurrency__c acctCurrency,
                                                          c2g__codaGeneralLedgerAccount__c glAccount) {
        
        List<c2g__codaPeriod__c> periods = [
            select Id
            from c2g__codaPeriod__c
            where 
                c2g__StartDate__c <= :Date.today() and 
                c2g__EndDate__c >= :Date.today()
        ];

        Id periodId = null;
        if (!periods.isEmpty()) {
            periodId = periods.get(0).Id;
        }

        c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(
            CurrencyIsoCode = 'USD', 
            c2g__Account__c = acc.Id,
            c2g__DerivePeriod__c = false,
            c2g__Period__c = periodId,
            c2g__DueDate__c = Date.today(),
            c2g__FirstDueDate__c = Date.today(), 
            c2g__Interval__c = 'Monthly',
            c2g__InvoiceDate__c = Date.today(),
            c2g__InvoiceStatus__c = 'In Progress',
            c2g__PrintStatus__c = 'Not Printed',
            c2g__SalesTaxStatus__c = 'Not Calculated',
            c2g__UnitOfWork__c = 2.0,
            ffbext__Approved__c = false,
            ffpsai__BillingEvent__c = billingEvent.Id, 
            c2g__InvoiceCurrency__c = acctCurrency.Id,
            c2g__OwnerCompany__c = company.Id,
            c2g__CopyAccountValues__c = true,
            c2g__CustomerReference__c = 'Cust Ref',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__InvoiceDescription__c = 'Description',
            c2g__InvoiceRate__c = 10.0,
            c2g__StartDate__c = Date.today()

        );

        insert invoice;
        return invoice;
    }

    private static c2g__codaInvoiceLineItem__c createSILI(c2g__codaInvoice__c invoice, pse__Billing_Event_Item__c bei, Product2 product) {
        c2g__codaInvoiceLineItem__c sili = new c2g__codaInvoiceLineItem__c(
            CurrencyIsoCode = 'USD',
            c2g__DeriveLineNumber__c = true,
            c2g__LineDescription__c = 'Time Entry',
            c2g__Quantity__c = 1.0,
            c2g__TaxRate1__c = 0.0,
            c2g__TaxRate2__c = 0.0,
            c2g__TaxRate3__c = 0.0,
            c2g__TaxValue1__c = 0.0,
            c2g__TaxValue2__c = 0.0, 
            c2g__TaxValue3__c = 0.0,
            c2g__UnitOfWork__c = 1.0,
            c2g__UnitPrice__c = 180.0,
            c2g__UsePartPeriods__c = true,
            c2g__UseProductInformation__c = false,
            c2g__Invoice__c = invoice.Id, 
            ffpsai__BillingEventItem__c = bei.Id,
            c2g__Product__c = product.Id
        );
        
        return sili;
    }

    private static c2g__codaGeneralLedgerAccount__c createGLAccount() {
        long l = (long) (Math.random() * 10000000.0);
        String rCode = String.valueOf(l);

        c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c(
            Name = rCode + ' - Test GLA',
            c2g__ReportingCode__c = rCode,
            c2g__Type__c = 'Balance Sheet'
        );
        insert glAccount;
        return glAccount;
    }

    private static Product2 createProduct(c2g__codaGeneralLedgerAccount__c glAccount) {
        Product2 product = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true,
            c2g__CODASalesRevenueAccount__c = glAccount.Id
        );
        insert product;

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert pbEntry;
        return product;
    }

    private static c2g__codaCompany__c getCompany() {
        List<c2g__codaCompany__c> companies = [
            select Id
            from c2g__codaCompany__c
            where Name = 'The Advisory Board Company'
        ];

        System.assertEquals(1, companies.size());
        c2g__codaCompany__c company = companies.get(0);
        return company;
    }

    private static c2g__codaAccountingCurrency__c getAccountingCurrency(c2g__codaCompany__c company) {
        List<c2g__codaAccountingCurrency__c> currencies = [
            select Id, Name
            from c2g__codaAccountingCurrency__c
            where c2g__OwnerCompany__c = :company.Id
        ];

        System.assert(currencies.size() > 0);
        return currencies.get(0);
    }

    private static pse__Miscellaneous_Adjustment__c createAdminFeeMA(pse__Proj__c project, Line_Item_Schedule__c lis) {
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c(
            Name = 'Admin Fee',
            pse__Effective_Date__c = Date.today(),
            pse__Amount__c = 100.0,
            pse__Transaction_Category__c = 'Ready-to-Bill Revenue',
            pse__Status__c = 'Approved',
            pse__Approved__c = true,
            pse__Include_In_Financials__c = true,
            pse__Project__c = project.Id,
            Line_Item_Schedule__c = lis.Id
        );
        insert miscAdj;
        return miscAdj;
    }
}