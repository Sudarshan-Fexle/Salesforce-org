//02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations
//03/18/2014 - CR-20120208-412 - Invalid parameter value "000000000000000" for parameter "id"
//04/19/2014 - CR-20140331-4909 - Updates to batch failure process - Modify by - Abhinav Sharma
//08/12/2014 - CR-20140506-5358 - Modified By Abhinav Sharma - Added Limits.getLimitDMLStatements() in CronTrigger SOQL
//02/29/2016 - CR-20160114-9516 - modified By - Abhinav Sharma - Added code to invoke "Batch_UpdateRIMemberHealthSnapshotFields" 
global class Batch_MeetingUtilizations implements Database.Batchable<SObject>, Database.Stateful {
    
    public String Query;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_MeetingUtilizations()
    {
        Date dt = Date.today();
        String datetoday = String.valueof(dt);
        debugLogStr = '';
        
        if (Query == null) {

            //02/14/2014 - CR-20120823-1396 - Commented By Abhinav Sharma - Remove subquery in Batch_MeetingUtilizations
            /*Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
                'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c,' +
                '(Select Start_Date__c, End_Date__c, Id FROM Meeting_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)), ' +
                '(SELECT Start_Date__c, End_Date__c  FROM Teleconference_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)) FROM Membership__c ' +
                'WHERE Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY ' +
                'OR Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365';*/
                
            //02/14/2014 - CR-20120823-1396 - Added By Abhinav Sharma - Remove subquery in Batch_MeetingUtilizations
            Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
                'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c ' +
                'FROM Membership__c ' +
                'WHERE Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY ' +
                'OR Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365';
                
        }
    } 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        List<Membership__c> memberships = (List<Membership__c>)scope;
        Util.IsBatch = true;
        
        //Modified By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        String logMessage = MeetingUtilities.UpdateMeetingSummary(memberships);
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage; 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Updated By Abhinav Sharma - 08/12/2014 - CR-20140506-5358 - Added Limits.getLimitDMLStatements() in CronTrigger SOQL 
        //Updated By Abhinav Sharma - 03/18/2014 - CR-20120208-412 - Invalid parameter value "000000000000000" for parameter "id"  
        // find all scheduled jobs with no Next Fire date and un-schedule them... 
        // Why keep them if they've already fired!?
        for (CronTrigger job : [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()]) {
            try {
                system.abortJob(job.Id);
            } catch(Exception ex) {
                if(ex.getMessage().contains('Invalid parameter value'))
                    continue;
                else if(ex.getMessage().contains('Job does not exist or is already aborted'))
                    continue;
                else
                    throw new CustomException(ex.getMessage());
            }  
        }
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MeetingUtilizations', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Added By -Abhinav Sharma - 02/29/2016 - CR-20160114-9516
        //Start from here
        //Start the next batch by kicking off a scheduled job
        //the reason we don't just piggyback 
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_UpdateRIMemberHealthSnapshotFields schedCon = new Sched_UpdateRIMemberHealthSnapshotFields();
        
        //Schedule the next job, and give it the system time so name is unique
        if(!Test.isRunningTest())
            System.schedule('Sched_UpdateRIMemberHealthSnapshotFields' + sysTime.getTime(), chron_exp, schedCon);
        
    	//Upto here
    }
}