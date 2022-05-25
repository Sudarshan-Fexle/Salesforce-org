global class Sched_Account_v2 implements Schedulable
{
    /*
    Purpose:    Runs after midnight and kicks off Batch_Account_OutreachProgs_v2.  Includes test method.
    
    Create By:          Nathan Banas (SAP) - 2/9/2011
    
    Last Modified By:   Nathan Banas (SAP) - 4/21/2011
    
    Current Version:    v1.3
    
    Revision Log:       v1.0 - (NB-2011-02-09) Created code as Sched_Account
                        v1.1 - (JN-3/17/11) Modified batchsize to 25 (originally 50). Smaller batch size avoids "too many query rows" governor exception
                        v1.2 - (JN 3/21/11) Created new Class as Sched_Account_v2 and saved, to avoid problem saving original Class.
                        v1.3 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                        v1.4 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.5 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
                        
    Code Coverage as of 2/9/2011: 100%
    Code Coverage as of 4/21/2011: 100%
    */

    //Reduce batch size to 5 to avoid governor overruns on SOQL rows - 11/1/12 vh
    global Integer batchsize = 5;
    
    public Id batchprocessid;
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    public boolean ScheduleHasRun = false;
    
    global Sched_Account_v2()
    {
        
    }

    global void execute(SchedulableContext ctx)
    {
        //Call Batch with specified batch size
        Batch_Account_OutreachProgs_v2 batch = new Batch_Account_OutreachProgs_v2();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        batch.ExecuteNextJob = true;
        
        //Execute Batch Job
        batchprocessid = Database.executeBatch(batch, batchsize); 
        
        if (batchprocessid != null)
           ScheduleHasRun = true;
    }
     
    
    /****** Testing *******/
    
    static testmethod void testSched()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        // bypass dupeblocker and other triggers
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        //Util.IsTesting = true;
        Util.ByPassAllTriggers = true;
        
        // Create test accounts & memberships & programs
        List<Account> testAccts = new List<Account>();
        List<Membership__c> testMembs = new List<Membership__c>();
        List<Program__c> testProgs = new List<Program__c>();
        list<string> progbuslines = new list<string>{'RI', 'PT', 'TD', 'CM'};

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        Util.ByPassAllTriggers = false;
        
        for(integer i = 0; i < 250; i++)
        {
            testAccts.add(new Account(Name='Test Acct'+i));
        }
        insert testAccts;
        
        for(Account a : testAccts)
        {
            testMembs.add(new Membership__c(Name='Memb ' + a.Name, Account_Name__c = a.id, Program__c = testProgram.Id));
        }
        insert testmembs;
        
        integer i = 0;
        for(Membership__c m : testMembs)
        {
            if(i >= progbuslines.size())
                i = 0;
            
            testProgs.add(new Program__c(Name='Test', Business_line__c=progbuslines[i]));
            
            i++;
        }
        
test.StartTest();  
            
        // Schedule the test job
        Sched_Account_v2 sched = new Sched_Account_v2();
        system.assertEquals(false, sched.ScheduleHasRun);
        
        String jobId = System.schedule('testSched_Account_v2',
            Sched_Account_v2.CRON_EXP, sched);

        Test.stopTest();
         
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
        
        // Verify the job has now run
        //system.assertEquals(True, sched.ScheduleHasRun);
    }
}