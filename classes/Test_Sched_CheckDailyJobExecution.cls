/*
Purpose         :   Test class for Sched_CheckDailyJobExecution

Create By       :   Rajeev Jain

Created Date    :   08/18/2020

Current Version :   V1.0

Revision Log    :   V1.0 - Created - By Rajeev Jain - CR-20200805-14403 - 08/18/2020 - Test the Sched_CheckDailyJobExecution functionality
                :   V1.1 - Modified By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Added "Scheduler_CreateSBRequest" scheduler

Coverage        :   100%
*/
@isTest(seeAllData=false)
private class Test_Sched_CheckDailyJobExecution {
    
    //Daily Scheduled Jobs Names
    //Added By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Added "Scheduler_CreateSBRequest" scheduler
    public static final Set<String> dailySchedJobsNames = new Set<String>{'%'+System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS+'%','%'+System.Label.SCHEDULER_BATCHCREATESBREQUESTPROCESS+'%','%'+System.Label.SCHEDULER_CREATESBREQUEST+'%'};
    
    //Apex Jobs Status values
    public static final Set<String> apexJobStatus = new Set<String>{Constants.APEXJOBSTATUS_QUEUED, Constants.APEXJOBSTATUS_PREPARING, Constants.APEXJOBSTATUS_PROCESSING};
    
    //This method is used to cover the use case
    //When No Schedule Apex Class (Scheduler_BatchOrgComparisonAnalysis,Scheduler_BatchCreateSBRequestProcess) is Running
    @isTest    
    static void test_CheckDailyJobExecutionNoSchedApexRunning() 
    {
        // When No Schedule Apex Class is Running
        List<AsyncApexJob> asyncApexJobBeforeScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assertEquals(0, asyncApexJobBeforeScheClassRun.size());
        
        Test.StartTest();
        Sched_CheckDailyJobExecution.scheduleAfterTime();
        Test.stopTest();
        
        // After Sched_CheckDailyJobExecution Job Execution Check Asserts
        List<AsyncApexJob> asyncApexJobAfterScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assertEquals(2, asyncApexJobAfterScheClassRun.size());
    }
    
    //This method is used to cover the use case
    //When both the Schedule Apex Classes (Scheduler_BatchOrgComparisonAnalysis,Scheduler_BatchCreateSBRequestProcess) are Running
    @isTest    
    static void test_CheckDailyJobExecutionWhenBothSchedApexRunning()    
    {
        // When both the Jobs are already running 
        Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(1, null, null);
        Scheduler_BatchCreateSBRequestProcess.scheduleAfterMinutes(2, false, null,false);
        
        Test.StartTest();
        
        List<AsyncApexJob> asyncApexJobBeforeScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assert(true, asyncApexJobBeforeScheClassRun.size()>0);
        
        Sched_CheckDailyJobExecution.scheduleAfterTime();
        
        Test.stopTest();
        
        // After Sched_CheckDailyJobExecution Job Execution Check Asserts
        List<AsyncApexJob> asyncApexJobAfterScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assert(true, asyncApexJobAfterScheClassRun.size()>0);
    }
    
    //This method is used to cover the use case
    //When Only Scheduler_BatchOrgComparisonAnalysis Job is Running
    @isTest    
    static void test_CheckDailyJobExecutionWhenBatchOrgCompRunning() 
    {
        // When Only Scheduler_BatchOrgComparisonAnalysis Job is Running
        Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(1, null, null);
        
        Test.StartTest();
        
        List<AsyncApexJob> asyncApexJobBeforeScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assertEquals(1, asyncApexJobBeforeScheClassRun.size());
        System.assert(true, asyncApexJobBeforeScheClassRun[0].ApexClass.Name.contains(System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS));
        
        Sched_CheckDailyJobExecution.scheduleAfterTime();
        
        Test.stopTest();
        
        List<AsyncApexJob> asyncApexJobAfterScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assert(true, asyncApexJobAfterScheClassRun[0].ApexClass.Name.contains(System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS));
        System.assert(true, asyncApexJobAfterScheClassRun[1].ApexClass.Name.contains(System.Label.SCHEDULER_BATCHCREATESBREQUESTPROCESS));
    }
    
    //This method is used to cover the use case
    //When Only Scheduler_BatchCreateSBRequestProcess Job is Running
    @isTest    
    static void test_CheckDailyJobExecutionWhenBatchCreateSBRunning() 
    {
         // When Only Scheduler_BatchCreateSBRequestProcess Job is Running
        Scheduler_BatchCreateSBRequestProcess.scheduleAfterMinutes(2, false, null,false);
        
        Test.StartTest();
        
        List<AsyncApexJob> asyncApexJobBeforeScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assertEquals(1, asyncApexJobBeforeScheClassRun.size());
        //Added By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Added "Scheduler_CreateSBRequest" scheduler
        System.assert(true, asyncApexJobBeforeScheClassRun[0].ApexClass.Name.contains(System.Label.SCHEDULER_CREATESBREQUEST));
        
        Sched_CheckDailyJobExecution.scheduleAfterTime();
        
        Test.stopTest();
        
        List<AsyncApexJob> asyncApexJobAfterScheClassRun = [SELECT Id, ApexClass.Name, JobType FROM AsyncApexJob WHERE Status IN: apexJobStatus
                                                             AND ApexClass.Name Like: dailySchedJobsNames
                                                             AND JobType =: Constants.ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX
                                                            ];
        System.assert(true, asyncApexJobAfterScheClassRun[1].ApexClass.Name.contains(System.Label.SCHEDULER_BATCHORGCOMPARISONANALYSIS));
        //Added By - Shalu Sharma - CR-20211210-15621 - 12/10/2021 - Added "Scheduler_CreateSBRequest" scheduler
        System.assert(true, asyncApexJobAfterScheClassRun[0].ApexClass.Name.contains(System.Label.SCHEDULER_CREATESBREQUEST));
    }
}