/*
    Purpose:    Scheduler to schedule Batch_PopulateRNIAMRestrictionsOnAccount batch process 
                CR-20111006-148
    
    Create By:  Simplyforce - Bhavi - 12/17/2011
    
    Current Version:    v1.0
    
    Revision Log:       Created.
*/
global class Sched_PopulateRNIAMRestrictionsOnAccount implements Schedulable {
    
    //override execute method
    global void execute(SchedulableContext ctx) {

        //Call Batch with specified batch size
        Database.executeBatch(new Batch_PopulateRNIAMRestrictionsOnAccount(), 25);
    }
    
    //test method for scheduler
    static testmethod void testSched() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Start test here 
        Test.StartTest();  
        
        //Cron expression
        String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
            
        //call scheduler
        String jobId = System.schedule('testSched_PopulateRNIAMRestrictionsOnAccount', CRON_EXP,
                                         new Sched_PopulateRNIAMRestrictionsOnAccount());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [select TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, OwnerId, NextFireTime,Id, EndTime, CronExpression from CronTrigger where id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        //Stop test here 
        Test.stopTest();
    }
}