/*
    Purpose:    Populate RNI AM Restrictions field on Account records with the SUM of 
                CR-20111006-148
    
    Create By:  Simplyforce - Bhavi - 12/15/2011
    
    Current Version:    v1.0
    
    Revision Log:       v1.0 Created.
                        v1.1 Modified By - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.2 - modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
                        v1.3 Modified By - Victor Hanson - 06/02/2014 -  CR-4283 - Added reference to Sched_DeactivateInactiveCommunityUsers
                        v1.4 - Modified By - Abhinav Sharma - 08/12/2014 - CR-20140506-5358 - Added Limits.getLimitDMLStatements() in CronTrigger SOQL
						v1.5 - Modified By - Abhinav sharma - to clean up the Batch Refernces. CR-20180521-12234
*/
    
global class Batch_PopulateRNIAMRestrictionsOnAccount  implements Database.Batchable<SObject>, Database.Stateful {
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    public string Query = null;
    
    global Batch_PopulateRNIAMRestrictionsOnAccount () {
        debugLogStr = '';
    }
    
    //override start method to initiate the init processing
    global Database.queryLocator start(Database.BatchableContext BC) {
        
        //Modified By - Abhinav Sharma - 04/21/2014 - CR-20140331-4909
        //Check if test method is running
        if(Test.isRunningTest()) {
        
            //Query to fecth Accounts with related Restriction MTM records
            return Database.getQueryLocator('Select Id, RNI_AM_Restrictions__c, (Select RNI_AM_Restriction__c from Restrictions_MtM__r  where Restriction_Status__c  = \'Active\') from Account order by CreatedDate DESC limit 10');
        
        }  else {
        
            if(Query == null) {
                Query = 'Select Id, RNI_AM_Restrictions__c, (Select RNI_AM_Restriction__c from Restrictions_MtM__r where Restriction_Status__c  = \'Active\') from Account';
            }
        
            //Query to fecth Accounts with related Restriction MTM records
            return Database.getQueryLocator(Query);
        }
    }
    
    //process the result reurned by start method
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
        
        //List of account records to be updated
        List<Account> accountsToUpdate = new List<Account>();
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //loop through the query results and populate RNI AM Restriction field
        for(Account account : (List<Account>)scope) {
            
            //Total RMI AM Restrictions
            Double totalRMIAMRestrinction = 0;
            
            //loop through the account's related Restrictions_MtM records
            if(account.Restrictions_MtM__r != null && account.Restrictions_MtM__r.size() > 0) {
                for(Restricted_MtM__c restrictiomMtM : account.Restrictions_MtM__r) {
                    totalRMIAMRestrinction = totalRMIAMRestrinction + restrictiomMtM.RNI_AM_Restriction__c;
                }
            }
            
            //check the accounts RNI_AM_Restrictions__c and update this field only if it has beed changed since last time
            if(account.RNI_AM_Restrictions__c != totalRMIAMRestrinction) {
                
                //populate SUM of restrictions MtM records on Account
                account.RNI_AM_Restrictions__c = totalRMIAMRestrinction;
                accountsToUpdate.add(account);
            }
            
            //Checking list for size value
            if(accountsToUpdate.size() > 0) {
            
                //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
                //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
                logMessage = Util.createLog(Database.update((accountsToUpdate),false));
                
                //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
                if(logMessage != '') 
                    debugLogStr += logMessage; 
            }   
        }
    }
    
    //method for post processing
    global void finish(Database.BatchableContext ctx) {
        
        //Updated By Abhinav Sharma - 08/12/2014 - CR-20140506-5358 - Added Limits.getLimitDMLStatements() in CronTrigger SOQL
        //Added By - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Unschedule any jobs where NextFireTime = null.  
        //This will prevent the accumulation of scheduled jobs that are never going to be fired from appearing in the Scheduled Apex page.
        //Find all scheduled jobs with no Next Fire date and un-schedule them... 
        for (CronTrigger job : [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()]) {
            try {
                system.abortJob(job.Id);
            } catch(Exception ex) {
                if(ex.getMessage().contains('Invalid parameter value'))
                    continue;
                else
                    throw new CustomException(ex.getMessage());
            }  
        }
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_PopulateRNIAMRestrictionsOnAccount', debugLogStr, sfAdminUser[0].Email);
        }
        
        // VRH 3/7/12 - start the next batch by kicking off a scheduled job
        //Build the system time of now + 20 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_MembershipNextActivityDate membershipNextActivityDate = new Sched_MembershipNextActivityDate();
    
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Sched_MembershipNextActivityDate' + sysTime.getTime(),chron_exp,membershipNextActivityDate);
		
        //Commented by Abhinav sharma - to clean up the Batch Refernces. CR-20180521-12234
        //Schedule the deactivateInactiveCommunityUsers batch CR-4283
        //System.schedule('Sched_DeactivateInactiveCommunityUsers' + sysTime.getTime(),chron_exp,new Sched_DeactivateInactiveCommunityUsers());
    
     //Commented by Abhinav sharma - to clean up the Batch Refernces. CR-20180521-12234
        //Schedule the deactivateInactiveCommunityUsers batch CR-4283
        //System.schedule('Sched_DeactivateInactiveCommunityUsers' + sysTime.getTime(),chron_exp,new Sched_DeactivateInactiveCommunityUsers());
    
        //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors, 
                             CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        
        String emailMessage = 
            'Your batch job \"Batch_PopulateRNIAMRestrictionsOnAccount\" has finished.  It processed ' 
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
        mail.setSubject('Batch_PopulateRNIAMRestrictionsOnAccount job completed');
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}