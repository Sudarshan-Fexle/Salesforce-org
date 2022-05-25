/*
    Purpose:
       The Test class for SetProjectStatusReportDate.  
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    1/9/2013
*/

@isTest(SeeAllData=true)
public with sharing class SetProjectStatusReportDateTest {
	
    static testMethod void testProjectStatusReportDate() {
        pse__Proj__c testProject = new pse__Proj__c(  
            Name='test',
            pse__Is_Active__c=true,
            pse__Is_Billable__c=true,
            pse__Allow_Timecards_Without_Assignment__c=true,
            pse__Allow_Expenses_Without_Assignment__c=true
        );
        insert testProject;
        
        pse__Work_Calendar__c wc = new pse__Work_Calendar__c(
            Name='Test Calendar',
            pse__Week_Start_Day__c = 'Saturday'
        );
        insert wc;
        
        Test.startTest();
        
        Datetime dt = DateTime.now().addSeconds(30);
        String cronExp = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + 
                         ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule(
            'testSetProjectStatusReportDate',
            cronExp,
            new SetProjectStatusReportDate(wc.Name, testProject.Id));
        
        Test.stopTest();

        pse__Proj__c project = [
            select 
                Status_Report_Week_Ending__c
            from pse__Proj__c
            where Id = :testProject.Id
        ];
        
        System.assertEquals(endDateOfLastWeek(wc.Name), project.Status_Report_Week_Ending__c);
    }
    
    private static Date endDateOfLastWeek(String calendarName) {
        List<pse__Work_Calendar__c> workCalendars = [
            select pse__Week_Start_Day__c
            from pse__Work_Calendar__c
            where Name = :calendarName
        ];
        
        String weekStart = 'Sunday';
        if (!workCalendars.isEmpty()) {
            weekStart = workCalendars[0].pse__Week_Start_Day__c;
        }
        
        Date refDate = referenceDate(weekStart);
        Date weekStartDate = Date.today();
        Integer daysBetween = refDate.daysBetween(weekStartDate);
        while (Math.mod(daysBetween, 7) != 0) {
            weekStartDate = weekStartDate.addDays(-1);
            daysBetween = refDate.daysBetween(weekStartDate);
        }
        
        return weekStartDate.addDays(-1);
    }
    
    private static Date referenceDate(String weekStart) {
    	Date refDate = Date.newInstance(1900, 1, 7);
        if (weekStart.equals('Monday')) {
            refDate = Date.newInstance(1900, 1, 1);
        }
        else if (weekStart.equals('Tuesday')) {
            refDate = Date.newInstance(1900, 1, 2);
        }
        else if (weekStart.equals('Wednesday')) {
            refDate = Date.newInstance(1900, 1, 3);
        }
        else if (weekStart.equals('Thursday')) {
            refDate = Date.newInstance(1900, 1, 4);
        }
        else if (weekStart.equals('Friday')) {
            refDate = Date.newInstance(1900, 1, 5);
        }
        else if (weekStart.equals('Saturday')) {
            refDate = Date.newInstance(1900, 1, 6);
        }
        
        return refDate;
    }
}