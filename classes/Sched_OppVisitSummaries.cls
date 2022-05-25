global class Sched_OppVisitSummaries implements Schedulable
{
    /*
    Purpose:    Runs after midnight and kicks off Batch_ConfirmActiveContract.  Includes test method.
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Nathan Banas (SAP) - 1/26/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-26) Added header, code comments, and reviewed code coverage
                        v1.2 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        
    Code Coverage as of 1/26/2011: 100%
    */
    
    //Reduce batch size to 50 to avoid governor overruns on SOQL rows
    global Integer batchsize = 50;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    
    global Sched_OppVisitSummaries()
    {
        
    }
    
    global void execute(SchedulableContext ctx)
    {
        Batch_Opportunity_VisitSummaries batch = new Batch_Opportunity_VisitSummaries();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        batch.ExecuteNextJob = true;
        
        //Execute Batch
        //Applied the batch size to ensure that governer limit hit related error occurance will reduce
        batchprocessid = Database.executeBatch(batch, 30);
        
        if (batchprocessid != null)
            Util.ScheduleHasRun = true;
    }
    
    /****** Testing *******/
    
    static testmethod void testSched()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        system.assertEquals(false, Util.ScheduleHasRun);
        
        
        test.StartTest();  
            
        // Schedule the test job
        Sched_OppVisitSummaries sched = new Sched_OppVisitSummaries();
        
        String jobId = System.schedule('testSched_OppVisitSummaries',
            Sched_OppVisitSummaries.CRON_EXP, sched);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_OppVisitSummaries.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        ct = [SELECT TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, 
            OwnerId, NextFireTime,Id, EndTime, CronExpression   FROM CronTrigger WHERE id = :jobId];
        
        system.debug('\n\n52 ct ' + ct);        
        
        Test.stopTest();
        
        // Verify the job has now run
        system.assertEquals(True, Util.ScheduleHasRun);
    }
}