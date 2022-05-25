global class Batch_CheckDeletedATMs implements Database.Batchable<sObject>, Database.Stateful
{
    /*
    Purpose:   Monitor changed Account Team Members
                If changed ATM is "AE or EA" type
                    query Accounts with ATMs
                    populate Account AE_EA__c field with UserID from ATM
                If changed ATM is "Marketer" type
                    query Accounts with those ATMs and associated Memberships
                    for each Membership, evaluate whether Assigned Marketer needs to change
                    for each Membership, evaluate whether OwnerId needs to change
                    
    
    Create By:          Jeremy Nottingham (8/30/11)
    
    Last Modified By:   Jeremy Nottingham (9/20/11) 
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (JN 8/30/11) Created code
                        v1.1 - (JN 8/30/11) Substantially changed logic, added comments, refined test code
                        v1.2 - (JN 9/20/11) fixed error in querystring
                        v1.3 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.4 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
						v1.5 - Modify by - Abhinav Sharma - CR-20180521-12234 - Remove the refernces.
    */
    public String debuglog = ''; // Variable to store errors to return in the completion email
    public Integer totalprocessed = 0; // Variable to store number of records processed
    Public String Query;
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_CheckDeletedATMs () {
        debugLogStr = '';
    }
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        if (Query == null)
        {
            Query = 'Select Id, EA_AE__c, EA_Contact__c,'
                + ' (Select TeamMemberRole, UserId from AccountTeamMembers where TeamMemberRole like \'%Executive Advisor&\''
                //+ ' or TeamMemberRole like \'%Account Exec%\' or TeamMemberRole = \'EA or AE\' limit 1)'
                + ' or TeamMemberRole like \'%Account Exec%\' or TeamMemberRole = \'AE or EA\' limit 1)'
                + ' from Account where EA_AE__c != null or EA_Contact__c != null';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Util.IsBatch = true;
        List<Account> accs = (list<Account>)scope;
        set<id> eaaeids = new set<Id>();
        totalprocessed += accs.size();
        
        for (Account a : accs) {
            if (a.AccountTeamMembers.size() == 0) {
                a.EA_AE__c = null;
            } else {
                a.EA_AE__c = a.AccountTeamMembers[0].UserId;
                eaaeids.add(a.EA_AE__c);
            }
        }
        
        list<Contact> eacontacts = [select Id, Employee_User_Record__c from Contact where Employee_User_Record__c in :eaaeids];
        map<Id, Contact> userid2conmap = new map<Id, Contact>();
        for (Contact c : eacontacts) {
            userid2conmap.put(c.Employee_User_Record__c, c);
        }
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Checking list for size value
        if(accs.size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((accs),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
        
        //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        /*try {
            update accs;
        } catch (Exception e)
        {
            debuglog += '<br/> Exception:<br/>' + e.getMessage();
        }*/
             
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
			//List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
			//if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_CheckDeletedATMs', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        	
            /* Schedular is Deleted - CR-20180521-12234 - Abhinav Sharma
            //Scheduler class
            Sched_MonitorTMs_Recordtypes controller = new Sched_MonitorTMs_Recordtypes();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_MonitorTMs_Recordtypes' + sysTime.getTime(),chron_exp,controller); */
            
			//CR-20180830-12532 - 	SFMOD-1811-95531
            //schedule relationship interaction job
            //System.schedule('Schedule_RelationshipInteractionForTask' + sysTime.getTime(),chron_exp,new Schedule_RelationshipInteractionForTask());
            //System.schedule('Schedule_RelationshipInteractionForEvent' + sysTime.getTime(),chron_exp,new Schedule_RelationshipInteractionForEvent());
        }
    }
}