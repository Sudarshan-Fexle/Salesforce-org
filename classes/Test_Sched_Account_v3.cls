/**
 *    Purpose			:    Test Class for Sched_Account_v3
 *   
 *    Create By			:    Nikita Kumari - 07/12/2021
 *    
 *    Current Version		:    V1.0 - CR-20211005-15489
 *    
 *    Revision Log		:    Created.
 **/
@isTest(seeAllData = false)
public with sharing class Test_Sched_Account_v3 {
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //CRON notation for 9/3/2022 00:00:00, for testing
    public boolean ScheduleHasRun = false;
    
    static testMethod void Test_Test_Sched_Account_v3() {
        
        //Bypass Dupeblocker
        Util.IsTest(true); 
        //Bypass Dupeblocker
        Util.IsTest(true); 
        
        // Create test accounts & memberships & programs
        List<Account> testAccts = new List<Account>();
        List<Membership__c> testMembs = new List<Membership__c>();
        List<Program__c> testProgs = new List<Program__c>();
        list<string> progbuslines = new list<string>{'RI', 'PT', 'TD', 'CM'};
            
        //Bypass all trigger
        Util.byPassAllTriggers = true;
        
        List<User> sfAdminUser = [Select Id, Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
        
	//Create custom setting record 
        //Custom Setting Data 
        User_InActive_Ownership_To_SFAdmin__c inactiveOwnershipData = new User_InActive_Ownership_To_SFAdmin__c();
        inactiveOwnershipData.Batch_Size__c = 20;
        inactiveOwnershipData.Last_N_Hours__c = 24;
        inactiveOwnershipData.SFAdmin_Id__c = sfAdminUser[0].Id;
        insert inactiveOwnershipData;
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //Bypass all trigger
        Util.byPassAllTriggers = false;
        
        for(integer i = 0; i < 10; i++)
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
        Sched_Account_v3 sched = new Sched_Account_v3();
        //system.assertEquals(false, sched.ScheduleHasRun);
        
        String jobId = System.schedule('testSched_Account_v3',
                                       Sched_Account_v3.CRON_EXP, sched);
        Test.stopTest();
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(Sched_Account_v3.CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered); 
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        ct = [SELECT TimesTriggered, TimeZoneSidKey, State, StartTime, PreviousFireTime, 
              OwnerId, NextFireTime,Id, EndTime, CronExpression FROM CronTrigger WHERE id = :jobId];
        
        system.debug('\n\n52 ct ' + ct);
        
    }
}