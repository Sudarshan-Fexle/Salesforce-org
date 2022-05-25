@isTest
private class TestSchedConfirmActiveContract 
{   
      
    static testmethod void testSched()
    { 
        String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        system.assertEquals(false, Util.ScheduleHasRun);
        
        test.StartTest();  
            
        // Schedule the test job
        Sched_ConfirmActiveContract sched = new Sched_ConfirmActiveContract();
        
        String jobId = System.schedule('testSched_ConfirmActiveContract',
            CRON_EXP, sched);
        System.debug('***** JOB ID: ' + jobId);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];
        System.debug('***** CT: ' + ct);
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
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