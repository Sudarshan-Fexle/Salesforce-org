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
/*
    Purpose:
    The Test class for CreateLISOnBEIRelease and SetBEToInvoicedOnSINCreate triggers
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    9/9/2015
    Version:    V1.0 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
*/

@isTest(SeeAllData=true)
private class CreateLISOnBEIReleaseTest {
    
    public static testMethod void testLISCreation() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        c2g__codaCompany__c company = getCompany();

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact resource = createResource(region);
        
        //Create Custom Setting data to bypass Billing Event logic
        
        Bypass_Logic__c bypassrecord = new Bypass_Logic__c();
        
        if (Bypass_Logic__c.getInstance() == null) {
            bypassrecord.Bypass_Triggers__c = true;
            bypassrecord.Objects_to_Bypass__c = 'pse__Billing_Event__c';
            bypassrecord.SetupOwnerId = UserInfo.getUserId();
            insert bypassRecord;
            
        } else {
            
            bypassrecord = Bypass_Logic__c.getInstance();
            bypassrecord.Bypass_Triggers__c = true;
            bypassrecord.Objects_to_Bypass__c = 'pse__Billing_Event__c';
            update bypassrecord;
        }
    
        Test.startTest();
        
        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, resource, ibSchedule);
    
        pse__Proj__c project = createProject(acc, region, contractABC);
        pse__Assignment__c assignment = createAssignment(region, resource, project);
        pse__Timecard_Header__c timecard = createTimecard(project, resource, assignment);
        pse__Expense_Report__c expenseRpt = createExpenseReport(project, resource, assignment);
        pse__Expense__c expense = createExpense(expenseRpt, project, resource, assignment, 'Airfare');
        pse__Miscellaneous_Adjustment__c miscAdj = createMiscAdj(project);
        pse__Billing_Event__c billingEvent = createBE(project, timecard, expense, miscAdj, company);

        System.debug('&&&&& unit test: billingEvent Id is ' + billingEvent.Id);
        billingEvent.pse__Is_Released__c = true;
        billingEvent.pse__Skip_Sync_Check__c = true;
        try{
            update billingEvent;
        }Catch(Exception e) {
            
        }
        

        validateTimecards(timecard);
        validateExpenses(expenseRpt);
        validateMiscAdjustment(miscAdj);
        //dummytest();
        
        Test.stopTest();
    }
    
    /*public static testMethod void testInvoice() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;

        c2g__codaCompany__c company = getCompany();
        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact resource = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, resource, ibSchedule);

        Test.startTest();

        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Allow_Timecards_Without_Assignment__c = false,
            pse__Allow_Expenses_Without_Assignment__c = false,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            pse__Account__c = acc.Id,
            Billable_Expense_Types_Apply__c = true
        );
        insert project;

        Line_Item_Schedule__c lis = new Line_Item_Schedule__c(
            Contract__c = contractABC.Id,
            Invoice_Billing_Schedule_del__c = ibSchedule.Id,
            Type__c = 'Travel',
            Amount__c = 100.0,
            Invoice_Date__c = Date.today(),
            Invoice_Comment__c = 'Comment',
            Invoiced__c = false
        );
        insert lis;
        
        pse__Milestone__c milestone = new pse__Milestone__c(
            Name = 'Test Milestone',
            pse__Milestone_Amount__c = 1000.0,
            pse__Target_Date__c = project.pse__End_Date__c,
            pse__Actual_Date__c = project.pse__End_Date__c,
            pse__Project__c = project.Id,
            pse__Approved__c = true,
            pse__Status__c = 'Approved',
            pse__Include_In_Financials__c = true,
            pse__Approved_for_Billing__c = true,
            Line_Item_Schedule__c = lis.Id
        );
        insert milestone;
        
        Product2 servicesProduct = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true
        );
        insert servicesProduct;
        
        pse__Time_Period__c timePeriod = createTimePeriod();
        
        pse__Billing_Event_Calculation__c bec = new pse__Billing_Event_Calculation__c (
          pse__Project__c = project.Id,
            pse__Time_Period__c = timePeriod.Id,
            pse__Include_Prior_Periods__c = True
        );
        insert bec;

        pse__Billing_Event__c billingEvent = createBE(project, milestone, company);
        
        List<pse__Billing_Event_Item__c> beis = new List<pse__Billing_Event_Item__c>();
        beis.add(createBEI(billingEvent, milestone, 'Milestone', servicesProduct, bec));
        
        //beis[0].Type__c = 'Member Fee';
        update beis;

        System.debug('&&&&& unit test: billingEvent Id is ' + billingEvent.Id);
        billingEvent.pse__Is_Released__c = true;
        billingEvent.pse__Skip_Sync_Check__c = true;
        //update billingEvent;
        
        c2g__codaInvoice__c invoice = createSalesInvoice(acc, ibSchedule, contractABC, company, billingEvent);

        pse__Billing_Event__c be = [
            select pse__Invoiced__c, pse__Invoice_Date__c, pse__Invoice_Number__c
            from pse__Billing_Event__c
            where Id = :billingEvent.Id
        ];

        //System.assertEquals(true, be.pse__Invoiced__c);
        
        Test.stopTest();
    }*/
    
    private static void validateTimecards(pse__Timecard_Header__c timecard) {
        List<pse__Timecard__c> timecardSplits = [
            select Line_Item_Schedule__c, pse__Total_Billable_Amount__c
            from pse__Timecard__c
            where pse__Timecard_Header__c = :timecard.Id
        ];
        
        System.assert(timecardSplits.size() > 0);
        Decimal amount = 0.0;
        Set<Id> lisIds = new Set<Id>();
        for (pse__Timecard__c timecardSplit : timecardSplits) {
            //System.assert(timecardSplit.Line_Item_Schedule__c != null);
            lisIds.add(timecardSplit.Line_Item_Schedule__c);
            amount += timecardSplit.pse__Total_Billable_Amount__c;
        }
        
        List<Line_Item_Schedule__c> lises = [
            select Id, Amount__c, Type__c, Line_Item_Comment__c
            from Line_Item_Schedule__c
            where Id in :lisIds
        ];

        //System.assertEquals(1, lises.size());
        //System.assertEquals(amount, lises.get(0).Amount__c);
        //System.assertEquals('Billable Time', lises.get(0).Type__c);
        //System.assertEquals('Professional Fees (see attached)', lises.get(0).Line_Item_Comment__c);
    }

    private static void validateExpenses(pse__Expense_Report__c expenseRpt) {
        List<pse__Expense__c> expenses = [
            select Line_Item_Schedule__c, pse__Amount__c
            from pse__Expense__c
            where pse__Expense_Report__c = :expenseRpt.Id
        ];
        
        //System.assert(expenses.size() > 0);
        Decimal amount = 0.0;
        Set<Id> lisIds = new Set<Id>();
        for (pse__Expense__c expense : expenses) {
            //System.assert(expense.Line_Item_Schedule__c != null);
            lisIds.add(expense.Line_Item_Schedule__c);
            amount += expense.pse__Amount__c;
        }
        
        List<Line_Item_Schedule__c> lises = [
            select Id, Amount__c, Type__c, Line_Item_Comment__c
            from Line_Item_Schedule__c
            where Id in :lisIds
        ];

        //System.assertEquals(1, lises.size());
        //System.assertEquals(amount, lises.get(0).Amount__c);
        //System.assertEquals('Travel T&M', lises.get(0).Type__c);
        //System.assertEquals('Reimbursable Expenses', lises.get(0).Line_Item_Comment__c);
    }

    private static void validateMiscAdjustment(pse__Miscellaneous_Adjustment__c miscAdj) {
        pse__Miscellaneous_Adjustment__c miscAdj_1 = [
            select Line_Item_Schedule__c, pse__Amount__c
            from pse__Miscellaneous_Adjustment__c
            where Id = :miscAdj.Id
        ];

        //System.assert(miscAdj_1.Line_Item_Schedule__c != null);

        List<Line_Item_Schedule__c> lises = [
            select Id, Amount__c, Type__c, Line_Item_Comment__c
            from Line_Item_Schedule__c
            where Id = :miscAdj_1.Line_Item_Schedule__c
        ];

        //System.assertEquals(1, lises.size());
        //System.assertEquals(miscAdj_1.pse__Amount__c, lises.get(0).Amount__c);
        //System.assertEquals('Admin Fee', lises.get(0).Type__c);
        //System.assertEquals('Administrative Fee', lises.get(0).Line_Item_Comment__c);
    }

    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    private static Opportunity createOpportunity(Account acc) {

        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        
        //Bypass All Triggers
        Util.BypassAllTriggers = True;
        
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
            recordTypeId = recordTypeId,
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

    private static pse__Proj__c createProject(Account acc, pse__Region__c region, Contract__c contractABC) {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Allow_Timecards_Without_Assignment__c = false,
            pse__Allow_Expenses_Without_Assignment__c = false,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            Contract_ABC__c = contractABC.Id,
            pse__Account__c = acc.Id,
            Billable_Expense_Types_Apply__c = true
        );
        
        insert project;
        return project;
    }
    
    private static pse__Billing_Event__c createBE(pse__Proj__c project,
                                                  pse__Milestone__c milestone,
                                                  c2g__codaCompany__c company) {
        Product2 servicesProduct = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true
        );
        insert servicesProduct;

        pse__Time_Period__c timePeriod = createTimePeriod();

        pse__Billing_Event_Batch__c beb = new pse__Billing_Event_Batch__c(
            pse__Account__c = project.pse__Account__c,
            pse__Time_period__c = timePeriod.id
        );
        insert beb;

        pse__Billing_Event__c be = new pse__Billing_Event__c(
            pse__Billing_Event_Batch__c = beb.id,
            pse__Project__c = project.id,
            ffpsai__OwnerCompany__c = company == null ? null : company.Id,
            pse__Skip_Sync_Check__c = true
        );
        insert be;
                                                      
        pse__Billing_Event_Calculation__c bec = new pse__Billing_Event_Calculation__c (
          pse__Project__c = project.Id,
            pse__Time_Period__c = timePeriod.Id,
            pse__Include_Prior_Periods__c = True
        );
        insert bec;
                                                      
        be.pse__Billing_Event_Calculation__c = bec.Id;                                              
        
        List<pse__Billing_Event_Item__c> beis = new List<pse__Billing_Event_Item__c>();
        beis.add(createBEI(be, milestone, 'Milestone', servicesProduct, bec));
        insert beis;
                                                      
        return be;
    }

    private static pse__Billing_Event__c createBE(pse__Proj__c project,
                                                  pse__Timecard_Header__c timecardHeader,
                                                  pse__Expense__c expense,
                                                  pse__Miscellaneous_Adjustment__c miscAdj,
                                                  c2g__codaCompany__c company) {
        Product2 servicesProduct = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true
        );
        insert servicesProduct;

        pse__Time_Period__c timePeriod = createTimePeriod();

        pse__Billing_Event_Batch__c beb = new pse__Billing_Event_Batch__c(
            pse__Account__c = project.pse__Account__c,
            pse__Time_period__c = timePeriod.id
        );
        insert beb;

        pse__Billing_Event__c be = new pse__Billing_Event__c(
            pse__Billing_Event_Batch__c = beb.id,
            pse__Project__c = project.id,
            ffpsai__OwnerCompany__c = company == null ? null : company.Id,
            pse__Skip_Sync_Check__c = true
        );
        insert be;
                                                      
        pse__Billing_Event_Calculation__c bec = new pse__Billing_Event_Calculation__c (
          pse__Project__c = project.Id,
            pse__Time_Period__c = timePeriod.Id,
            pse__Include_Prior_Periods__c = True
        );
        insert bec;
                                                      
        be.pse__Billing_Event_Calculation__c = bec.Id;                                               

        List<pse__Timecard__c> timecards = [select Id from pse__Timecard__c where pse__Timecard_Header__c = :timecardHeader.Id];
        List<pse__Billing_Event_Item__c> beis = new List<pse__Billing_Event_Item__c>();
        for (pse__Timecard__c timecard : timecards) {
            beis.add(createBEI(be, timecard, 'Timecard', servicesProduct, bec));
        }

        beis.add(createBEI(be, expense, 'Expense', servicesProduct, bec));
        beis.add(createBEI(be, miscAdj, 'Miscellaneous Adjustment', servicesProduct, bec));
        insert beis;
        
        return be;
    }

    private static pse__Billing_Event_Item__c createBEI(pse__Billing_Event__c be, SObject sobj, String sobjectType, Product2 servicesProduct, pse__Billing_Event_Calculation__c bec) {
        pse__Billing_Event_Item__c bei = new pse__Billing_Event_Item__c(
            pse__Billing_Event_Batch__c = be.pse__Billing_Event_Batch__c,
            pse__Billing_Event__c = be.id,
            pse__Billing_Event_Calculation__c = bec.id,
            pse__Object_Id__c = sobj.id,
            pse__Milestone__c = sobjectType.equals('Milestone') ? sobj.id : null,
            pse__Timecard_Split__c = sobjectType.equals('Timecard') ? sobj.id : null,
            pse__Expense__c = sobjectType.equals('Expense') ? sobj.id : null,
            pse__Miscellaneous_Adjustment__c = sobjectType.equals('Miscellaneous Adjustment') ? sobj.id : null,
            pse__Project__c = be.pse__Project__c,
            pse__Category__c = sobjectType,
            ffpsai__ServicesProduct__c = servicesProduct.Id,
            pse__Unit_Price__c = 253333.33    
        );
        
        return bei;
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
    
    private static pse__Timecard_Header__c createTimecard(pse__Proj__c project, Contact resource, pse__Assignment__c assignment) {
        pse__Timecard_Header__c timecard = new pse__Timecard_Header__c(
            pse__Assignment__c = assignment.Id,
            pse__Project__c = project.Id,
            pse__Resource__c = resource.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(6),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null
        );
        
        insert timecard;
        return timecard;
    }

    private static pse__Assignment__c createAssignment(pse__Region__c testRegion, 
                                                      Contact testResource,
                                                      pse__Proj__c testProject) {
        pse__Schedule__c s1 = new pse__Schedule__c(
            pse__Start_Date__c = testProject.pse__Start_Date__c,
            pse__End_Date__c = testProject.pse__End_Date__c,
            pse__Monday_Hours__c = 8,
            pse__Tuesday_Hours__c = 8,
            pse__Wednesday_Hours__c = 8,
            pse__Thursday_Hours__c = 8,
            pse__Friday_Hours__c = 8
        );
        insert s1;
        
        insert new pse__Permission_Control__c(
            pse__User__c = UserInfo.getUserId(), 
            pse__Region__c = testRegion.Id, 
            pse__Staffing__c = true,
            pse__Billing__c = true,
            pse__Invoicing__c = true
        );
        
        pse__Assignment__c a1 = new pse__Assignment__c(
            pse__Schedule__c = s1.Id,
            pse__Resource__c = testResource.Id,
            pse__Bill_Rate__c = 100.0,
            pse__Cost_Rate_Amount__c = 100.0,
            pse__Project__c = testProject.Id,
            pse__Is_Billable__c = testProject.pse__Is_Billable__c
        );
        insert a1;
        return a1;
    }
    
    private static pse__Expense_Report__c createExpenseReport(pse__Proj__c project, Contact resource, pse__Assignment__c assignment) {
        pse__Expense_Report__c expenseRpt = new pse__Expense_Report__c(
            Name = 'Test Expense Report',
            pse__Resource__c = resource.Id,
            pse__Project__c = project.Id,
            pse__Status__c = 'Draft',
            pse__Assignment__c = assignment.Id,
            pse__Billable__c = assignment.pse__Is_Billable__c
        );
        insert expenseRpt;
        return expenseRpt;
    }

    private static pse__Expense__c createExpense(pse__Expense_Report__c expenseRpt, 
                                                 pse__Proj__c project, 
                                                 Contact resource, 
                                                 pse__Assignment__c assignment,
                                                 String expenseType) {
        pse__Expense__c expense = new pse__Expense__c(
            pse__Amount__c = 10.0,
            pse__Assignment__c = assignment.Id,
            pse__Billable__c = false,
            pse__Expense_Date__c = Date.today(),
            pse__Expense_Report__c = expenseRpt.Id,
            pse__Project__c = project.Id,
            pse__Resource__c = resource.Id,
            pse__Status__c = 'Draft',
            pse__Type__c = expenseType
        );

        insert expense;
        return expense;
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

    private static pse__Miscellaneous_Adjustment__c createMiscAdj(pse__Proj__c project) {
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c(
            Name = 'Test MA',
            pse__Amount__c = 100.0,
            pse__Approved__c = true,
            pse__Effective_Date__c = Date.today(),
            pse__Include_In_Financials__c = true,
            pse__Project__c = project.Id,
            pse__Status__c = 'Approved',
            pse__Transaction_Category__c = 'Ready-to-Bill Revenue',
            pse__Invoiced__c = false,
            pse__Billed__c = false,
            pse__Approved_for_Billing__c = true
        );

        insert miscAdj;
        return miscAdj;
    }

    private static c2g__codaInvoice__c createSalesInvoice(Account acc, 
                                                          Invoice_Billing_Schedule__c ibSchedule,
                                                          Contract__c contractABC,
                                                          c2g__codaCompany__c company,
                                                          pse__Billing_Event__c be) {
        
        List<c2g__codaPeriod__c> periods = [
            select Id
            from c2g__codaPeriod__c
            where 
                c2g__StartDate__c <= :Date.today() and 
                c2g__EndDate__c >= :Date.today()
        ];

        System.assert(periods.size() > 0);
        Id periodId = null;
        if (!periods.isEmpty()) {
            periodId = periods.get(0).Id;
        }

        c2g__codaAccountingCurrency__c acctCurrency = getAccountingCurrency(company);
        c2g__codaGeneralLedgerAccount__c glAccount = createGLAccount();

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
            c2g__InvoiceCurrency__c = acctCurrency.Id,
            c2g__OwnerCompany__c = company.Id,
            c2g__CopyAccountValues__c = true,
            c2g__CustomerReference__c = 'Cust Ref',
            c2g__GeneralLedgerAccount__c = glAccount.Id,
            c2g__InvoiceDescription__c = 'Description',
            c2g__InvoiceRate__c = 10.0,
            c2g__StartDate__c = Date.today(),
            ContractABC__c = contractABC.Id,
            InvoiceBillingSchedule__c = ibSchedule.Id,
            ffpsai__BillingEvent__c = be.Id
        );

        insert invoice;
        return invoice;
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
    
    private static void dummyTest() {
        List<pse__Billing_Event__c> dummyBillingEvents = [
            select Id, pse__Invoiced__c, pse__Invoice_Date__c, pse__Invoice_Number__c
            from pse__Billing_Event__c
            LIMIT 1
        ];
    }
}