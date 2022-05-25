global class Batch_OAB_Lead_Passer implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose:    Updates field Today__c on OAB_Lead_Passer w/ today's date.
                This batch is also part of a nightly scheduled job.
    
    Create By:  Nathan Banas (SAP) - 2/23/2011
    
    Last Modified By:   Nathan Banas (SAP) - 2/23/2011
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 - (NB-2011-02-23) Created code.
                        v1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.2 - modify by - Abhinav Sharma - 04/18/2014 - CR-20140331-4909 - Updates to batch failure process
        
    Code Coverage as of 2/23/2011: 97%
    */
    
    public string Query = null;
    
    date TodaysDate = system.today();
    
    String debuglog = '\n';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_OAB_Lead_Passer ()
    {
        debugLogStr = '';
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE id = :ctx.getJobId()];
        
        System.debug('### Current Query: ' + Query);

        if(Query == null)
        {
            Query = 'select Id, Today__c from OAB_Lead_Passer__c Order By CreatedDate desc';
        }
        
        System.debug('### Executing Batch for Query: ' + Query);
        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.IsBatch = true;
        
        list<OAB_Lead_Passer__c> recordList = (list<OAB_Lead_Passer__c>)scope;
        
        for(OAB_Lead_Passer__c r : recordList)
        {
            r.Today__c = TodaysDate;
            totalprocessed++;
        }
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Checking list for size value
        if(recordList.size() > 0) {
        
            //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((recordList),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
    }
    
    global void finish(Database.BatchableContext ctx)
    {
              
        //Added By Abhinav Sharma - 04/18/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_OAB_Lead_Passer', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_DailyEventCounts controller = new Sched_DailyEventCounts();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_DailyEventCounts' + sysTime.getTime(),chron_exp,controller);
        }
        
    }
    
    static testmethod void testBatch_OAB_Lead_Passer()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        util.IsBatch = true;
        Util.IsTesting = true;
        
        // Create test Warm Lead (required on OAB Lead Passer)
        Warm_Lead__c testWl = new Warm_Lead__c(Name=system.today() + ' New Warm Lead', Lead_Date__c = system.today(), Lead_Channel__c = 'OAB', Status__c = 'Pending');
        insert testWl;        
        
        // Create test OAB_Lead_Passers
        List<OAB_Lead_Passer__c> testOABLPs = new List<OAB_Lead_Passer__c>();
        
        for(integer i = 0; i < 10; i++)
        {
            if(i < 8)
                testOABLPs.add(new OAB_Lead_Passer__c(Name='TestOAB' + i.format(), Department__c = 'MA', Warm_Lead__c = testWl.Id));
            else
                testOABLPs.add(new OAB_Lead_Passer__c(Name='TestOAB' + i.format(), Department__c = 'MA', Warm_Lead__c = testWl.Id, Today__c = system.today().addDays(-1)));
        }
        
        insert testOABLPs;
        
        // Start testing
        Batch_OAB_Lead_Passer batch = new Batch_OAB_Lead_Passer();
        batch.Query = 'select Id, Today__c from OAB_Lead_Passer__c Order By CreatedDate desc limit 10';
        
        test.startTest();
        id batchId = database.executeBatch(batch);
        System.debug('### Launched Batch : '+ batchId);
        test.stopTest();
        
        system.debug('### Total Processed:' + batch.totalprocessed.format());
        
        system.assertNotEquals(null, batchId);
        
        OAB_Lead_Passer__c checkOAB = [select Id, Today__c from OAB_Lead_Passer__c where Id = :testOABLPs[5].Id];
        
        system.assertNotEquals(null, checkOAB.Today__c);
    }
}