//V_1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
global class Sched_CheckRestrictionExpiration implements Schedulable {

    global Integer batchsize = 10;  // DAF was 50 
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    
    global Sched_CheckRestrictionExpiration() {
    }

    global void execute(SchedulableContext ctx) {

        //Call Batch with specified batch size
        Batch_CheckRestrictionExpiration bcre = new Batch_CheckRestrictionExpiration();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        bcre.ExecuteNextJob = true;
        
        //Execute Batch
        batchprocessid = Database.executeBatch(bcre, batchsize);
        
    }
     
    static testmethod void testSched() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        test.StartTest();  
            
        // Schedule the test job
        Sched_CheckRestrictionExpiration sched = new Sched_CheckRestrictionExpiration();
        
        String jobId = System.schedule('testSched_CheckRestrictionExpiration', Sched_CheckRestrictionExpiration.CRON_EXP, sched);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [select TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, OwnerId, NextFireTime,Id, EndTime, CronExpression from CronTrigger where id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_CheckRestrictionExpiration.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }

}