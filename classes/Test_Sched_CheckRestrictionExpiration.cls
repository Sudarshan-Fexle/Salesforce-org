/**
 * Purpose            :    This class is used to test Sched_CheckRestrictionExpiration
 *
 * Created By         :    Abhishek Mishra
 *
 * Current Version    :    V_1.0
 *
 * Revision Log       :    V_1.0 - Abhishek Mishra - CR-20211005-15489 - 07/13/2021
 **/
@isTest (SeeAllData=false)
private class Test_Sched_CheckRestrictionExpiration
{
    //Method to test Sched_CheckRestrictionExpiration
    static testmethod void testSched_CheckRestrictionExpiration() 
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        util.BypassAllTriggers = true;
        
        //Create Institution
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Name = 'DrewTestAccount';
        acct.Account_Formal_Name__c = 'DrewTestAccount';
        update acct;
        
        //Create Contact
        Contact cont = TestUtilities.CreateNewContact(acct, false);
        cont.AccountId = acct.Id;
        cont.Company_Email__c = 'test@royall.com';
        cont.Title = 'Test';
        cont.Phone = '614-555-8855';
        insert cont;
        
        //Create Restriction
        Restrictions__c restriction = new Restrictions__c(Expiration_Date__c = Date.today().addDays(5));
        insert restriction;
        
        //Create Restricted MtM 
        Restricted_MtM__c restrictionMTM = new Restricted_MtM__c(Account__c = acct.Id, Contact__c = cont.Id, Restriction__c = restriction.Id, Restriction_Expired__c = false);
        insert restrictionMTM;
        
        //Updating Expiration date 
        restriction.Expiration_Date__c = system.today().addDays(-2);
        update restriction;
        
        util.BypassALltriggers = false;
        
        Test.StartTest();  
        
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