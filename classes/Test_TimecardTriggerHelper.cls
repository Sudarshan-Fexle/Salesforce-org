@isTest(SeeAllData=false)
private class Test_TimecardTriggerHelper {
    
    public static testMethod void testTimeRollup() {
        
        Util.ByPassAllTriggers = true;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;
        
        pse__Proj__c project = createProject(region, acc);
        Contact resource = createResource(region);
        pse__Assignment__c assignment = createAssignment(region, resource, project);
        pse__Timecard_Header__c timecard = createTimecard(project, resource, assignment);
        
        List<pse__Time_Date__c> timeDates = new List<pse__Time_Date__c>();
        timeDates.add(new pse__Time_Date__c(pse__Timecard__c = timecard.Id, pse__Hours__c = 10, pse__Date__c = system.today().addDays(3)));
        timeDates.add(new pse__Time_Date__c(pse__Timecard__c = timecard.Id, pse__Hours__c = 5, pse__Date__c = system.today().addDays(2)));
        timeDates.add(new pse__Time_Date__c(pse__Timecard__c = timecard.Id, pse__Hours__c = 6, pse__Date__c = system.today().addDays(1)));
        
        insert timeDates; 
        
        //submit time card before approve
        timecard.pse__Status__c = 'Submitted';
        Update timecard;
        
        Util.ByPassAllTriggers = false;
        
        test.startTest();
        //approve time card
        timecard.pse__Status__c = 'Approved';
        Update timecard;
        
        List<pse__Proj__c> projList = [Select Id,Year_1_Actual_Hours__c,Year_2_Actual_Hours__c,Year_3_Actual_Hours__c,Year_4_Actual_Hours__c,Year_5_Actual_Hours__c From pse__Proj__c
                                      where Id =: project.Id];
        system.assertEquals(21,projList[0].Year_1_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_2_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_3_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_4_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_5_Actual_Hours__c);
        test.stopTest();
    }
    
    //Created by - Chirag Soni - CR-20220405-16067 - 05/24/2022 - Code coverage increase part
    public static testMethod void testTimeRollupV2() {
        
        Util.ByPassAllTriggers = true;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;
        
        pse__Proj__c project = createProject(region, acc);
        Contact resource = createResource(region);
        pse__Assignment__c assignment = createAssignment(region, resource, project);
        pse__Timecard_Header__c timecard = createTimecard(project, resource, assignment);
        
          pse__Timecard__c pseTimeCard = new pse__Timecard__c(pse__Project__c = project.Id,
                                                           pse__Status__c = Constants.TIMECARD_STATUS_APPROVED,
                                                           pse__Start_Date__c = system.today().addDays(1),
                                                           pse__End_Date__c = system.today().addDays(3));
        
        
        //submit time card before approve
        timecard.pse__Status__c = 'Submitted';
        Update timecard;
        
        Util.ByPassAllTriggers = false;
        
        test.startTest();
        //approve time card
        timecard.pse__Status__c = 'Approved';
        Update timecard;
        
        List<pse__Proj__c> projList = [Select Id,Year_1_Actual_Hours__c,Year_2_Actual_Hours__c,Year_3_Actual_Hours__c,Year_4_Actual_Hours__c,Year_5_Actual_Hours__c From pse__Proj__c
                                       where Id =: project.Id];
        system.assertEquals(21,projList[0].Year_1_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_2_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_3_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_4_Actual_Hours__c);
        system.assertEquals(21,projList[0].Year_5_Actual_Hours__c);
        test.stopTest();
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
            Year_1_Start_Date__c = system.today(),
            Year_2_Start_Date__c = system.today(),
            Year_3_Start_Date__c = system.today(),
            Year_4_Start_Date__c = system.today(),
            Year_5_Start_Date__c = system.today(),
            Year_1_End_Date__c = system.today().addDays(9),
            Year_2_End_Date__c = system.today().addDays(9),
            Year_3_End_Date__c = system.today().addDays(9),
            Year_4_End_Date__c = system.today().addDays(9),
            Year_5_End_Date__c = system.today().addDays(9),
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
            pse__Salesforce_User__c = UserInfo.getUserId(),
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true, 
            pse__Work_Calendar__c = wc.Id,
            MailingCountry = 'USA',
            pse__Resource_Role__c = 'Member Success',
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
}