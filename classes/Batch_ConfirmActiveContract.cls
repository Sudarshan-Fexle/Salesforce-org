/*
    Purpose:    This Class will be called by Sched_ConfirmActiveContract each night after midnight and will only operate on records 
                that have relevant dates that need to be checked against the current date. (Relevant = last 3 days)
                
                Processes:
                
                - Query for Contracts where Start__c or End__c are in the last three days through today
                    
                1.  Determine if Contract__c is “Active” or not: Contract is Active if Start__c <= TODAY and End__c >= TODAY. This is reflected by the checkbox field Active__c.
                    - Check each Contract for “Active”ness and update as necessary. (Active__c = TRUE)
                
                2.  Find Memberships that may be affected by changes in Contract Active status, and query all attached Contracts for those Memberships. 
                    This includes 
                    
                    Contracts where Payer Account = Membership Account and Program = Membership Program  
                    and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')
                    
                    Also include: Contracts where attached Contract Integrated Accounts have Account = Membership Account and Contract Program = Membership Program
                    
                    Go through all Contracts for each Membership and calculate fields:
                    
                        Active_Contract_Idenfied__c
                            The Active Contract Identified on a Membership is the Contract that has Start__c <= TODAY and  End__c >= TODAY with the latest End date of all connected Contracts. 
                            In other words, if there are 2 Active Contracts, choose the one with the later End Date. 
                            If there is none, look for the future Contract (Start__c > TODAY) with the earliest Start__c
                
                        Earliest_Contract__c
                            This is the Contract with the earliest Start__c of all related Contracts
                            
                        Latest_Contract__c
                            This is the Contract with the latest End__c of all related Contracts
    
    Create By:          Pierre Eymard
    
    Last Modified By:   Drew Freeman - 1/17/2012
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (JN-2011-01-20) Multiple edits to conform to needs of scheduled job
                        v1.2 - (NB-2011-01-26) Added header, code comments, and reviewed code coverage
                        v1.3 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.4 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process 
						v1.5 - Modify by - Victor Hanson - 10/15/2015 - CR-20150827-9195 - Remove references to Batch_OpportunityEvaluationCounts from the Batch_ConfirmActiveContract class.
    */
global class Batch_ConfirmActiveContract implements Database.Batchable<sObject>, Database.Stateful
{
    
    /* Variables */
    global String query = 'select id , Start__c, End__c, Program__c, Payer_Account__c, Active__c, CreatedDate from Contract__c'; // Variable to store the main query for this batch
    global Date dt = system.today(); // Variable to store today's date so it doesn't change between comparisons
    public Integer failedUpdates = 0; // Variable to store number of failed updates
    public Integer totalprocessed = 0; // Variable to store number of records processed
    set<id> MembershipIdstoCheck = new set<Id>(); // Variable to store Membership Ids to check for changes to
    public String debuglog = ''; // Variable to store errors to return in the completion email
    public Datetime startdatetime; // Variable to store the start date/time value of when this batch was started
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    // Constructor to initialize class
    global Batch_ConfirmActiveContract()
    {
        String datetoday = String.valueof(dt);
        String dateyesterday = String.valueOf(dt.addDays(-1));
        String dateThreeDaysAgo = String.valueOf(dt.addDays(-3));
        
        //SOQL filter. By default, only look at Contracts that may have changed Activeness in last three days: Just starting or just ended.
        query += ' where (Start__c >= ' + dateThreeDaysAgo + ' and Start__c <= ' + datetoday + ')' 
            + ' or (End__c >= ' + dateThreeDaysAgo + ' and End__c <= ' + dateyesterday + ') order by createddate desc';
                               
        if (Util.IsTesting) 
            query += ' limit 50'; // to limit records during tests
            
        debugLogStr = '';
    }
    
    // Method from Database.Batchable class called when the batch is started via database.executeBatch()
    global Database.Querylocator start(Database.BatchableContext BC)
    {        
        // Set the start date/time of this batch
        startdatetime = system.now();
        
        // Get the details from this job
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            from AsyncApexJob 
                           where Id = :BC.getJobId()];
        
        // Query for contracts to be returned to the execute(Database.BatchableContext, SObject[]) method
        system.debug('******************query**'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope)
    {
        List<Contract__c> ctstoupdate = new List<Contract__c>(); // Variable to store Contracts that need updates                                                          
       
        // Set the static IsBatch variable of the Utility class to ensure no triggers for the associated objects run 
        Util.IsBatch = true;
        
        //String to hold the log message
        String logMessage = '';
        
        // Translate the Query from the QueryLocator into a list of Contracts
        List<Contract__c> allcts = (list<Contract__c>)scope;                                                          
        
        // Display the Contract list to the debug log
        system.debug('\n\n************************  Found contracts'+allcts);
        
        Set<Id> memOwnerNeeded = new Set<Id>(); // DAF - added 12-15-11

        /**** APPLY THE RULE: Contract is Active if Start__c <= TODAY and End__c >= TODAY ***/
        for (Contract__c c: allcts) // Loop through each contract
        {
            totalprocessed++;
            debuglog += '<br/>c ' + c.id;
            
            system.debug('\n\n99 today ' + dt + '\nstart ' + c.Start__c );
            
            // If the Contract Start Date is less than or equal to today and
            // the Contract End Date is greater than or equal to today,
            // set the Contract Active field to true only if it is not already
            if (c.start__c <= dt && c.end__c >= dt)
            {
                if ((c.active__c == null) || (c.active__c == false))
                {
                    system.debug('\n\n102 c ' + c);
                    c.active__c = true;
                    ctstoupdate.add(c);
                }
            }
            else // If today is not between the Contract Start and End date then set the Contract Active field to false only if it is not already
            {
                if ((c.active__c == null) || (c.Active__c ==true))
                {
                    system.debug('\n\n108 c ' + c);
                    c.active__c = false;
                    ctstoupdate.add(c);
                }
            }
        }
        
        // Compile a list of contracts for debugging purposes that needed the Active flag set as true or false
        String conliststring = '';
        for (Contract__c c : ctstoupdate)
        {
            conliststring += '\n' + c.id + ' (' + c.Active__c + ' ' + c.Start__c.format() + ')';
        }
        
        system.debug('\n\n112 ctstoupdate (' + ctstoupdate.size() + ') ' + conliststring);
        
        //Update Contracts with proper status
        
        //Modified By - Abhinav Sharma -04/19/2014 - CR-20140331-4909
        //Checking list for size value
        if(ctstoupdate.size() > 0) {
        
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((ctstoupdate),false)); // false = we disallow partial successes
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }   
        
        //Commented By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        /*for(Database.Saveresult dbs: dbsr)
        {
          if(!dbs.isSuccess())
             failedUpdates++;
        }*/
        
        //Modfied By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
        /** Find the Memberships for these Contracts that need updated **/
        logMessage = ContractIntegratedAccountsTriggerHelper.populateContractsOnMembership(ctstoupdate, null);
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage; 
    }

    global void finish(Database.BatchableContext BC)
    {
        System.debug( '*************** inside finish method, failures = '+failedUpdates);
            
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
			//Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
			//List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
			//if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_ConfirmActiveContract', debugLogStr, Label.Salesforce_Admin_Email);
        }
        
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_MembershipSubscriptions membershipSubscriptions = new Sched_MembershipSubscriptions();
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Sched_MembershipSubscriptions' + sysTime.getTime(),chron_exp,membershipSubscriptions);
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime1 = System.now();
            sysTime1 = sysTime1.addSeconds(20);
            String chron_exp1 = '' + sysTime1.second() + ' ' + sysTime1.minute() + ' ' + sysTime1.hour() + ' ' + sysTime1.day() + ' ' + sysTime1.month() + ' ? ' + sysTime1.year();
        
            //Scheduler class
            Sched_OppVisitSummaries controller = new Sched_OppVisitSummaries();
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_OppVisitSummaries' + sysTime.getTime(),chron_exp,controller);
        }
    }
}