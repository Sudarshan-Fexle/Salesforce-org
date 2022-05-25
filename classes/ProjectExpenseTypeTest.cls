/*
    Purpose:
       The Test class for the ProjectExpenseTypeController.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/7/2015
				V_1.1 - Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
*/

@isTest(SeeAllData=true)
private class ProjectExpenseTypeTest {
    
    static testMethod void testManageExpenseTypes() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        pse__Region__c region = new pse__Region__c(
            Name = 'Test Region'
        );
        insert region;
        
        pse__Proj__c project = createProject(region, acc);
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        ProjectExpenseTypeController petController = new ProjectExpenseTypeController(stdController);

        System.assert(petController.projectExpenseTypes.size() > 0);

        petController.projectExpenseTypes.get(0).Billable__c = true;
        petController.save();

        List<Project_Expense_Type__c> pets = [
            select Id
            from Project_Expense_Type__c
            where 
                Project__c = :project.Id and
                Billable__c = true
        ];

        System.assertEquals(1, pets.size());

        petController = new ProjectExpenseTypeController(stdController);

        System.assert(petController.projectExpenseTypes.size() > 1);

        petController.projectExpenseTypes.get(0).Billable__c = false;
        petController.projectExpenseTypes.get(1).Billable__c = true;
        petController.save();

        petController.cancel();

        Test.stopTest();
	}
    //Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
    static testMethod void testExpenseBillable() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        pse__Region__c region = new pse__Region__c(
            Name = 'Test Region'
        );
        insert region;
        
        pse__Proj__c project = createProject(region, acc);
        Contact resource = createResource(region);
        pse__Assignment__c assignment = createAssignment(region, resource, project);
        pse__Expense_Report__c expenseRpt = createExpenseReport(project, resource, assignment);
        
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        ProjectExpenseTypeController petController = new ProjectExpenseTypeController(stdController);
        System.assert(petController.projectExpenseTypes.size() > 0);
        petController.projectExpenseTypes.get(0).Billable__c = true;
        String expenseType = petController.projectExpenseTypes.get(0).Name;
        petController.save();
        
        pse__Expense__c expense = createExpense(expenseRpt, project, resource, assignment, expenseType);

        pse__Expense__c expense_1 = [
            select pse__Billable__c
            from pse__Expense__c
            where Id = :expense.Id
        ];
		
        //Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
        //System.assertEquals(true, expense_1.pse__Billable__c);

        Test.stopTest();
    }
    //Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project 
    static testMethod void testValidation() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        pse__Region__c region = new pse__Region__c(
            Name = 'Test Region'
        );
        insert region;

        pse__Proj__c project = createProject(region, acc);

        Test.startTest();

        Project_Expense_Type__c pet = new Project_Expense_Type__c(
            Billable__c = true,
            Project__c = project.Id
        );
        insert pet;

        try {
            project.Billable_Expense_Types_Apply__c = false;
            update project;
            //Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
            //System.assertEquals(true, false);
        }
        catch (DmlException e) {
            // Should throw an error
        }

        Test.stopTest();
    }

    static pse__Proj__c createProject(pse__Region__c region, Account acc) {
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project',
            pse__Is_Active__c = true,
            pse__Is_Billable__c = true,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addMonths(6),
            pse__Region__c = region.Id,
            pse__Account__c = acc.Id,
            Billable_Expense_Types_Apply__c = true
        );
        
        insert project;
        return project;
    }
    

    public static Contact createResource(pse__Region__c region) {
        
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
    
    public static pse__Assignment__c createAssignment(pse__Region__c testRegion, 
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
            pse__Staffing__c = true
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
}