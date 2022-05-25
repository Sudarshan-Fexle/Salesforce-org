/*
    Purpose:
        The Test class for RollupTimeToAdminFeeMA trigger
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    8/17/2015
    Modified :  Modified By - 03/15/2017 - Rajeev Jain - Resolved Too many SOQL Error.
                Modified By - 12/13/2017 - Subhash Garhwal - System.DmlException - Issue--CR11831--QA--00007551
		Modified By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
                Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
*/

@isTest(SeeAllData=true)
private class RollupTimeToAdminFeeMATest {
    
    //03/15/2017 - Rajeev Jain - Resolved Too many SOQL Error. 
    //12/13/2017 - Subhash Garhwal - System.DmlException - Issue--CR11831--QA--00007551
    public static testMethod void testTimeRollup() {
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta

        Opportunity opp = createOpportunity(acc);
        Program__c program = createProgram();
        Contact contractContact = createResource(region);

        Invoice_Billing_Schedule__c ibSchedule = createInvoiceBillingSchedule(acc);
        Contract__c contractABC = createContractABC(acc, opp, program, contractContact, ibSchedule);
        
        Date projectStartDate = Date.today().toStartOfMonth();
        Date projectEndDate = projectStartDate.addMonths(6);
        pse__Proj__c project = createProject(acc, region, contractABC, projectStartDate, projectEndDate);
        pse__Assignment__c assignment = createAssignment(region, contractContact, project, 100.0);

        Date weekStart = projectStartDate.addMonths(1).addDays(-1).toStartOfWeek();
        Date weekEnd = weekStart.addDays(6);
        Integer numberOfExpectedMAs = 1;
        if (weekStart.month() != weekEnd.month()) {
            numberOfExpectedMAs = 2;
        }

        pse__Timecard_Header__c timecard1 = createTimecard(project, assignment, contractContact, weekStart, weekEnd, true, 8.0);
        verifyRollups(project, numberOfExpectedMAs);
        Util.BypassAllTriggers = true;
           
        timecard1.pse__Monday_Hours__c = 7.0;
        timecard1.pse__Admin_Global_Edit__c = true;
        timecard1.pse__Audit_Notes__c = 'A Note';
        //12/13/2017 - Subhash Garhwal - System.DmlException 
        timecard1.pse__Approved__c = false;
        timecard1.pse__Billable__c = true;
        timecard1.pse__Daily_Bill_Rate__c = true;
        timecard1.pse__Days_Worked_Override__c = 1;
        timecard1.pse__Sunday_Hours__c = 1;
        timecard1.pse__Monday_Hours__c  = 2;
        timecard1.pse__Bill_Rate__c = 0.0;
        timecard1.pse__Status__c = 'Approved';
        timecard1.pse__Approved__c = true;
        timecard1.pse__Submitted__c = true;
        timecard1.pse__Include_In_Financials__c = true;

        //Testing start here
        Test.StartTest();

        update timecard1;        
        //update timecard1;
        verifyRollups(project, numberOfExpectedMAs);

        //Testing stop here
        Test.StopTest(); 
        
    }
    //12/13/2017 - Subhash Garhwal - Resolved Too many SOQL Error.
    static testMethod void testtestTimeRollup1(){

        Date projectStartDate = Date.today().toStartOfMonth();
        Date projectEndDate = projectStartDate.addMonths(6);
        Account acc = [Select Id From Account Limit 1];
        Contract__c contractABC = [Select Id From Contract__c Limit 1];
        pse__Region__c region = [Select Id From pse__Region__c limit 1];
        pse__Proj__c project = createProject(acc, region, contractABC, projectStartDate, projectEndDate);
        pse__Assignment__c assignment = [Select Id From pse__Assignment__c Limit 1];
        Contact contractContact = [Select Id From Contact Limit 1];

        Date weekStart = projectStartDate.addMonths(1).addDays(-1).toStartOfWeek();
        Date weekEnd = weekStart.addDays(6);
        Integer numberOfExpectedMAs = 1;

        //Testing start here
        Test.StartTest();

       /*   pse__Timecard_Header__c timecard2 = [Select Id, pse__Status__c, pse__Approved__c,
                                                pse__Submitted__c, pse__Include_In_Financials__c From pse__Timecard_Header__c Limit 1 ];

        
        timecard2.pse__Status__c = 'Approved';
        timecard2.pse__Approved__c = true;
        timecard2.pse__Submitted__c = true;
        timecard2.pse__Include_In_Financials__c = true;
        update timecard2;
        verifyRollups(project, numberOfExpectedMAs);
        
        timecard2.pse__Status__c = 'Saved';
        timecard2.pse__Approved__c = false;
        timecard2.pse__Submitted__c = false;
        timecard2.pse__Include_In_Financials__c = false;
        //update timecard2;
        //verifyRollups(project, numberOfExpectedMAs);
        
        timecard2.pse__Status__c = 'Approved';
        timecard2.pse__Approved__c = true;
        timecard2.pse__Submitted__c = true;
        timecard2.pse__Include_In_Financials__c = true;
        update timecard2;
        verifyRollups(project, numberOfExpectedMAs);*/
        
        Test.stopTest();  
    }
    public static testMethod void testTimeRollupToBilledMA() {
        
        //Bypassing triggers
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

        Date projectStartDate = Date.today().toStartOfMonth();
        Date projectEndDate = projectStartDate.addMonths(1).addDays(-1);
        pse__Proj__c project = createProject(acc, region, contractABC, projectStartDate, projectEndDate);
        pse__Assignment__c assignment = createAssignment(region, contractContact, project, 100.0);

        Test.startTest();

        Date weekStart = projectStartDate.addDays(10).toStartOfWeek();
        Date weekEnd = weekStart.addDays(6);
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        pse__Timecard_Header__c timecard1 = createTimecard(project, assignment, contractContact, weekStart, weekEnd, true, 8.0);
        verifyRollups(project, 1);

        List<pse__Miscellaneous_Adjustment__c> mas = [
            select Id, pse__Billed__c
            from pse__Miscellaneous_Adjustment__c
            where pse__Project__c = :project.Id
        ];
        //System.assertEquals(1, mas.size());
        mas.get(0).pse__Billed__c = true;
        update mas;

        pse__Timecard_Header__c timecard2 = createTimecard(project, assignment, contractContact, weekStart, weekEnd, false, 1.0);
        verifyRollups(project, 1);
        
        timecard2.pse__Status__c = 'Approved';
        timecard2.pse__Approved__c = true;
        timecard2.pse__Submitted__c = true;
        timecard2.pse__Include_In_Financials__c = true;
        update timecard2;
        verifyRollups(project, 2);
        
        Test.stopTest();
    }
    
    private static void verifyRollups(pse__Proj__c project, Integer expectedNumberOfMAs) {
        Map<Id, pse__Miscellaneous_Adjustment__c> miscAdjustments = new Map<Id, pse__Miscellaneous_Adjustment__c>([
            select 
                Id,
                pse__Amount__c
            from pse__Miscellaneous_Adjustment__c
            where pse__Project__c = :project.Id
            order by pse__Effective_Date__c
        ]);

        //System.assertEquals(1, miscAdjustments.size());

        List<AggregateResult> aggResults = [
            select 
                Miscellaneous_Adjustment__c miscAdj,
                sum(pse__Total_Billable_Amount__c) totalAmount
            from pse__Timecard__c
            where pse__Project__c = :project.Id and pse__Approved__c = true
            group by Miscellaneous_Adjustment__c
        ];

        //System.assertEquals(expectedNumberOfMAs, aggResults.size());

        Decimal adminFeePercentage = project.Admin_Fee__c / 100.0;
        for (AggregateResult aggResult : aggResults) {
            Id maId = (Id) aggResult.get('miscAdj');
            pse__Miscellaneous_Adjustment__c miscAdj = miscAdjustments.get(maId);
        }
    }
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
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

    private static pse__Proj__c createProject(Account acc, pse__Region__c region, Contract__c contractABC, Date startDate, Date endDate) {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Start_Date__c = startDate,
            pse__End_Date__c = endDate,
            pse__Region__c = region.Id,
            Contract_ABC__c = contractABC.Id,
            pse__Account__c = acc.Id,
            pse__Billing_Type__c = 'Time and Materials',
            Admin_Fee__c = 10.0,
            Admin_Fee_Incl_in_Bill_Rate__c = false
        );
        
        insert project;
        return project;
    }

    public static pse__Assignment__c createAssignment(pse__Region__c testRegion, 
                                                      Contact testResource,
                                                      pse__Proj__c testProject,
                                                      Decimal billRate) {
        pse__Schedule__c s1 = new pse__Schedule__c(
            pse__Start_Date__c = testProject.pse__Start_Date__c.addDays(-1),
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
            pse__Timecard_Ops_Edit__c = true,
            pse__Billing__c = true
        );
        
        pse__Assignment__c a1 = new pse__Assignment__c(
            pse__Schedule__c = s1.Id,
            pse__Resource__c = testResource.Id,
            pse__Bill_Rate__c = billRate,
            pse__Cost_Rate_Amount__c = 100,
            pse__Project__c = testProject.Id,
            pse__Is_Billable__c = testProject.pse__Is_Billable__c
        );
        insert a1;
        return a1;
    }
    
    private static pse__Timecard_Header__c createTimecard(pse__Proj__c project,
                                                          pse__Assignment__c assignment, 
                                                          Contact resource,
                                                          Date startDate,
                                                          Date endDate,
                                                          boolean approved,
                                                          Decimal weekdayHours) {
        pse__Timecard_Header__c timecard = new pse__Timecard_Header__c(
            pse__Project__c = project.Id,
            pse__Resource__c = resource.Id,
            pse__Start_Date__c = startDate,
            pse__End_Date__c = endDate,
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = weekdayHours,
            pse__Tuesday_Hours__c = weekdayHours,
            pse__Wednesday_Hours__c = weekdayHours,
            pse__Thursday_Hours__c = weekdayHours,
            pse__Friday_Hours__c = weekdayHours,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = approved ? 'Approved' : 'Saved',
            pse__Submitted__c = approved ? true : false,
            pse__Include_In_Financials__c = approved ? true : false,
            pse__Approved__c = approved,
            pse__Approver__c = null,
            pse__Assignment__c = assignment.Id
        );
        insert timecard;
        return timecard;
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

    private static pse__Billing_Event_Item__c createBEI(pse__Billing_Event__c be, pse__Miscellaneous_Adjustment__c miscAdjustment) {
        Product2 servicesProduct = new Product2(
            Name = 'Test Product',
            pse__IsServicesProduct__c = true
        );
        insert servicesProduct;

        pse__Billing_Event_Item__c bei = new pse__Billing_Event_Item__c(
            pse__Billing_Event_Batch__c = be.pse__Billing_Event_Batch__c,
            pse__Billing_Event__c = be.id,
            pse__Object_Id__c = miscAdjustment.id,
            pse__Miscellaneous_Adjustment__c = miscAdjustment.id,
            pse__Project__c = be.pse__Project__c,
            pse__Category__c = 'Miscellaneous Adjustment',
            ffpsai__ServicesProduct__c = servicesProduct.Id
        );
        insert bei;
        return bei;
    }
}