/*
  Purpose:
        Once scheduled, this Apex class sets the Project Status Report
        Week Ending date to the end date of the previous week. It should
        therefore be scheduled to run on the first day of the week as defined
        by the Corporate calendar.
        
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    1/6/2012
*/

global class SetProjectStatusReportDate implements Schedulable {
    private String testCalendarName;
    private String testProjectId;
    private boolean inTestMode = false;
    
    global SetProjectStatusReportDate() {
        
    }

    global SetProjectStatusReportDate(String calendarName, Id projectId) {
        this.testCalendarName = calendarName;
        this.testProjectId = projectId;
        inTestMode = true;
    }

    global void execute(SchedulableContext SC) {
        String calName = (inTestMode ? this.testCalendarName : 'Corporate');
        Date weekEndDate = endDateOfLastWeek(calName);
        List<pse__Proj__c> projects = Database.query(projectQuery(weekEndDate));
        
        if (!projects.isEmpty()) {
            for (pse__Proj__c project : projects) {
                project.Status_Report_Week_Ending__c = weekEndDate;
            }
            
            update projects;
        }
    }
    
    private String projectQuery(Date weekEndDate) {
        String query =  
            'select ' +
                'Id, ' +
                'Status_Report_Week_Ending__c ' +
            'from pse__Proj__c ' +
            'where Status_Report_Week_Ending__c != ' + String.valueOf(weekEndDate);
        
        if (inTestMode) {
            query += ' and Id = \'' + this.testProjectId + '\'';
        }
            
        return query;
    }
    
    private Date endDateOfLastWeek(String calendarName) {
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
    
    private Date referenceDate(String weekStart) {
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