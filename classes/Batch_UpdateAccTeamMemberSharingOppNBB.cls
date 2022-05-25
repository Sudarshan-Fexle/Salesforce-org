/**
 *  Purpose         :   This batch is used for giving Mannual Sharing on Account Team Member as per below conditions:
 *                          1. If Institution Team Role is LIKE '%RM%' OR '%EA or AE%' AND Team Role NOT LIKE '%marketer%'. If the team member meets 
 *                              these criteria and there isn't an existing manual sharing record for this User and NBB record, create the 
 *                              manual sharing record.
 *                          2. If their team role doesn't meet the criteria and they have manual sharing for NBB records associated with that 
 *                              institution, delete the manual sharing records.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   11/15/2013
 *
 *  Current Version :   v1.0 - Created - CR-20130517-3034
 *                      v1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
 *                      v1.2 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process 
 * 						V1.3 - Modified By - Abhinav Sharma - 04/04/2018 - CR-20180404-12147 - Added the New Check to avoid the String Error     
 * 						V1.4 - Modified By - Victor Hanson - 07/23/2018 - CR-20180720-12460 - adjusted finish() method sysTime
 * 
 **/
global class Batch_UpdateAccTeamMemberSharingOppNBB implements Database.Batchable<SObject>, Database.Stateful {
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_UpdateAccTeamMemberSharingOppNBB() {
        debugLogStr = '';
    }
    
    //Start method
    global Database.Querylocator start(Database.BatchableContext BC) {
    
        //return query result
        return Database.getQueryLocator([SELECT Id, Opportunity__c, Opportunity__r.AccountId FROM NBB__c WHERE Opportunity__r.AccountId != null]);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<NBB__c> nBBs) {
        
        //Allow partial update
        Util.BypassAllTriggers = true;
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //Checking list for size value
        if(nBBs.size() > 0) {
        
            //Modified By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((nBBs),false));
            
            //Modified By Abhinav Sharma - 04/04/2018- CR-20180404-12147
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '' && logMessage.length() < 11999900) 
                debugLogStr += logMessage; 
        }   
    }    
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom labe
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin  
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateAccTeamMemberSharingOppNBB', debugLogStr, 
                                     Label.Salesforce_Admin_Email);
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = DateTime.now();
            sysTime = sysTime.addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_ConfirmActiveContract controller = new Sched_ConfirmActiveContract();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_ConfirmActiveContract' + sysTime.getTime(),chron_exp,controller);
        }
    }
}