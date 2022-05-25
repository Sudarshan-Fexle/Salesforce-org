global class Sched_DailyEventCounts implements Schedulable
{
    /*
    Purpose:    Runs after midnight and kicks off Batch_ActivityCount.  Includes test method.
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Nathan Banas (SAP) - 1/26/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-26) Added header, code comments, and added code coverage
                        v1.2 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        
    Code Coverage as of 1/26/2011: 100%
    */
    
    global Integer batchsize = 50;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing

    global Sched_DailyEventCounts()
    {
        
    }

    global void execute(SchedulableContext ctx)
    {
        Batch_ActivityCount bac = new Batch_ActivityCount();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        bac.ExecuteNextJob = true;
        
        //Execute Batch
        batchprocessid = Database.executeBatch(bac);
        
        if (batchprocessid != null)
            Util.ScheduleHasRun = true;
    }
    
    static testmethod void testSched()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        system.assertEquals(false, Util.ScheduleHasRun);

        test.StartTest();  
            
        // Schedule the test job
        Sched_DailyEventCounts sched = new Sched_DailyEventCounts();
        
        String jobId = System.schedule('testSched_DailyEventCounts',
            Sched_DailyEventCounts.CRON_EXP, sched);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_DailyEventCounts.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        ct = [SELECT TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, 
            OwnerId, NextFireTime,Id, EndTime, CronExpression FROM CronTrigger WHERE id = :jobId];
        
        system.debug('\n\n52 ct ' + ct);        
        
        Test.stopTest();
        
        
        // Verify the job has now run
        system.assertEquals(True, Util.ScheduleHasRun);
    }
}