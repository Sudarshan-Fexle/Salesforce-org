global class Sched_OAB_Lead_Passer implements Schedulable
{
    /*
    Purpose:    Runs after midnight and kicks off Batch_OAB_Lead_Passer.  Includes test method.
    
    Create By:          Nathan Banas (SAP) - 2/23/2011
    
    Last Modified By:   Nathan Banas (SAP) - 2/23/2011
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 - (NB-2011-02-23) Created code
                        v1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        
    Code Coverage as of 2/23/2011: 100%
    */

    //Reduce batch size to 50 to avoid governor overruns on SOQL rows
    global Integer batchsize = 50;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    
    global Sched_OAB_Lead_Passer()
    {
        
    }

    global void execute(SchedulableContext ctx)
    {
        //Call Batch with specified batch size
        Batch_OAB_Lead_Passer batch = new Batch_OAB_Lead_Passer();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        batch.ExecuteNextJob = true;
        
        //Execute Batch
        batchprocessid = Database.executeBatch(batch, batchsize);
        
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
        Sched_OAB_Lead_Passer sched = new Sched_OAB_Lead_Passer();
        
        String jobId = System.schedule('testSched_OAB_Lead_Passer',
            Sched_OAB_Lead_Passer.CRON_EXP, sched);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_Account_v2.CRON_EXP, ct.CronExpression);
        
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