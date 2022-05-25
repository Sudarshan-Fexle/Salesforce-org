//Simplyforce - Bhavi - 12/16/2011 - Added code to call Batch_PopulateRNIAMRestrictionsOnAccount - CR-20111006-148
//Simplyforce - Bhavi - 12/17/2011 - Newly Added code connented for Phase-I 
//Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
//Modify by - Abhinav Sharma - 03-07-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
//Modify By - Abhinav Sharma - 06/16/2015 - CR-20150422-8901 - Account Restrictions Issue
//Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
global class Batch_CheckRestrictionExpiration implements Database.Batchable<sObject>, Database.Stateful {
    
    //Commented By Abhinav Sharma - 03-07-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    //global String qry = 'select Id, Restriction_Expired__c from Restricted_MtM__c where Restriction_Expired__c = false and Restriction_Expiration_Date__c <= Today';
    
    //Added By Abhinav Sharma - 03-07-2014 - CR-20140204-4441 - Restriction status not being updated properly as part of nightly batch job
    global String qry = 'select Id, Restriction_Expired__c from Restricted_MtM__c where Restriction_Expired__c = false AND Restriction_Expiration_Date__c < Today AND (Contact__c != null OR Account__c != null)';

    //Commented By Abhinav Sharma - 03-07-2014 - CR-20140204-4441
    //public Integer totalprocessed = 0; // Variable to store number of records processed
    //public Integer numberOfErrors = 0; // Variable to store number of failed updates
    public Datetime startdatetime; // Variable to store the start date/time value of when this batch was started
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 03-07-2014 - CR-20140204-4441
    //String variable to hold the entire log message string value
    global String debugLog;
    
    //Added By - Abhinav Sharma - 06/16/2015 - CR-20150422-8901 - Account Restrictions Issue
    //Set to hold the restricted mtm records IDs where restriction_expired__c gets set to true
    global set<Id> rMTMIdSet = new set<Id>();

    global Batch_CheckRestrictionExpiration() {

        if (Util.IsTesting) { 
            qry += ' and Account__r.Name like \'%DrewTestAccount%\''; // to limit records during tests
        }
        
        debugLog = '';
    }

    // Method from Database.Batchable class called when the batch is started via database.executeBatch()
    global Database.Querylocator start(Database.BatchableContext BC) {        
        // Set the start date/time of this batch
        startdatetime = system.now();
        
        // Get the details from this job
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            from AsyncApexJob where Id = :BC.getJobId()];
        
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, SObject[] scope) {

        List<Restricted_MtM__c> rmtmList = (list<Restricted_MtM__c>)scope;                                                         
        system.debug('@@RMTMLIST: ' + rmtmList);
        
        //Modify By - Abhinav Sharma - 06/16/2015 - CR-20150422-8901
        //Updated By Abhinav Sharma - 03-07-2014 - CR-20140204-4441
        for (Restricted_MtM__c p : rmtmList) {      
            p.Restriction_Expired__c = true;
            rMTMIdSet.add(p.Id);
        }
        
        //String to hold the log message
        String logMessage = Util.createLog(Database.update((rmtmList),false));
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLog += logMessage;
    }
    //Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
    global void finish(Database.BatchableContext BC) {
        
        //Commented By Abhinav Sharma - 03-07-2014 - CR-20140204-4441
        //Checking logMessage string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' 
                                      AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_CheckRestrictionExpiration', debugLog, sfAdminUser[0].Email);
        }
        
        //Modify By - Abhinav Sharma - 06/16/2015 - CR-20150422-8901
        //Checking for set size and accordingly calling the batch to update the restrictions
        if(rMTMIdSet != null && rMTMIdSet.size() > 0) 
        //Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
        System.scheduleBatch(new Batch_RestrictionUpdate(rMTMIdSet),'Batch_RestrictionUpdate',0, 1);
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {
      
            /*Commented By Abhinav Sharma - CR-20180521-12234 - Removed the references of schedular Sched_CheckDeletedTMs
            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_CheckDeletedTMs controller = new Sched_CheckDeletedTMs();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_CheckDeletedTMs' + sysTime.getTime(),chron_exp,controller); */
        }
        
        //Commented By Abhinav Sharma - 03-07-2014 - CR-20140204-4441
        /*// Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
    
        // Retrive the current Job information
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        
        String emailMessage = 
            'Your batch job \"Batch_CheckRestrictionExpiration\" has finished.  It processed ' + totalprocessed + ' records in ' 
            + a.totalJobItems +
            ' batches.  Of which, ' 
            + a.jobitemsprocessed 
            + ' processed without any exceptions thrown and ' 
            + a.numberOfErrors 
            + ' batches threw unhandled exceptions.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.email};
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Batch'); 
        mail.setSubject('Batch_CheckRestrictionExpiration job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
        //Simplyforce - Bhavi - 12/16/2011 - Added code to call Batch_PopulateRNIAMRestrictionsOnAccount - CR-20111006-148
        //EmailHandler.sendEmail('serialize_batch_apex@5-473s1ld0rbhggnp02ovx92i6q.matkomag.m.apex.sandbox.salesforce.com', 'Invoke Another Batch', 'Execute_Batch_PopulateRNIAMRestrictionsOnAccount');
    }
}