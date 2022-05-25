/*
*   Description     :   Scheduler Class to Schedule Daily Jobs Automatically.
*
*   Created by      :   Rajeev Jain
*
*   Created Date    :   08/10/2020
* 
*   Revision Log    :   V_1.0 - CR-20200805-14403 - Created
                    :   V_1.0 - Modified By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Schedule Scheduler_CreateSBRequest scheduler in place of Scheduler_BatchCreateSBRequestProcess
*/
global class Sched_CheckDailyJobExecution implements Schedulable {
         
    //Daily Scheduled Jobs Names
    public static final Set<String> dailySchedJobsNames = new Set<String>{'%'+System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS+'%',/*'%'+System.Label.SCHEDULER_BATCHCREATESBREQUESTPROCESS+'%',*/'%'+System.Label.SCHEDULER_CREATESBREQUEST+'%'};
    
    //Apex Jobs Status values  
    public static final Set<String> apexJobStatus = new Set<String>{Constants.APEXJOBSTATUS_QUEUED, Constants.APEXJOBSTATUS_PREPARING, Constants.APEXJOBSTATUS_PROCESSING};
    
    //CRONTrigger State values
    public static final Set<String> cronTriggerState = new Set<String>{Constants.CRONTRIGGER_STATE_COMPLETE, Constants.CRONTRIGGER_STATE_DELETED};
    
    global void execute(SchedulableContext SC)
    {
        Boolean SchedulerBatchOrgComparisonAnalysisToKickoff = false;
    	Boolean SchedulerBatchCreateSBRequestProcessToKickoff = false;
        
        // Set to hold Apex Class Name that are in Queued
        set<String> asyncApexClassName = new set<String>();
        
        // Query to get the results for Queued Scheduled Apex Classes    
        for(AsyncApexJob iterateScheduledApexClass: [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                     AND ApexClass.Name Like: dailySchedJobsNames
                                                     AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                    ])
            {
                asyncApexClassName.add(iterateScheduledApexClass.ApexClass.Name);    
            }
        
        // When No Active Scheduled Apex
        if(asyncApexClassName.size() == 0 )
        {
            SchedulerBatchOrgComparisonAnalysisToKickoff = True;
            SchedulerBatchCreateSBRequestProcessToKickoff = True;
        }
        // Atleast 1 Active Scheduled Apex Jobs
        else if(asyncApexClassName.size() == 1)  
        {
            if(!asyncApexClassName.contains(System.Label.SCHEDULER_CREATESBREQUEST))
            {
            	SchedulerBatchCreateSBRequestProcessToKickoff = True;
            }
            else if(!asyncApexClassName.contains(System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS))
            {
                SchedulerBatchOrgComparisonAnalysisToKickoff = True;
            }
        }
        
        if(SchedulerBatchOrgComparisonAnalysisToKickoff == true)
        {
            Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(Integer.valueOf(System.Label.TIMETORUNSCHED_BATCHORGCOMPARISIONANALYSIS), null, null);
        }
        
        if(SchedulerBatchCreateSBRequestProcessToKickoff == true)
        { 
            //Modified By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Schedule Scheduler_CreateSBRequest scheduler in place of Scheduler_BatchCreateSBRequestProcess
	    //Scheduler_BatchCreateSBRequestProcess.scheduleAfterMinutes(Integer.valueOf(System.Label.TIMETORUNSCHED_BATCHCREATESBREQUESTPROCESS), false, null,false);
	    DateTime sysTime = dateTime.now().addMinutes(5);   
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Scheduler_CreateSBRequest sch = new Scheduler_CreateSBRequest(); 
            System.schedule('Scheduler_CreateSBRequest%', chron_exp, sch);
        }
        
        // Re-Scheduled Apex and Delete the Completed/Deleted records of Scheduled Apex
        Sched_CheckDailyJobExecution.scheduleAfterTime();
    }
    
    public static void scheduleAfterTime()  
    {
        String dailyJobExecutionName = '%'+System.Label.SCHED_CHECKDAILYJOBEXECUTION+'%';
        
        List<CronTrigger> JOBIDLIST = new List<CronTrigger>();
        JOBIDLIST = [select id from CronTrigger WHERE State IN:cronTriggerState AND CronJobDetail.Name like:dailyJobExecutionName AND NextFireTime = null Limit 149];
        for(CronTrigger job:JOBIDLIST )
        {
            System.abortJob(job.id);
        }

        DateTime sysTime = dateTime.now().addHours(Integer.valueOf(System.Label.TIMETORUNSCHED_CHECKDAILYJOBEXECUTION));
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_CheckDailyJobExecution sched_Job = new Sched_CheckDailyJobExecution();
        System.schedule(System.Label.SCHED_CHECKDAILYJOBEXECUTION + String.valueOf(Math.random()), chron_exp, sched_Job);
    }
}