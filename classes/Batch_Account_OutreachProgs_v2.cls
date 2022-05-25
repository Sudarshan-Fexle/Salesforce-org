global class Batch_Account_OutreachProgs_v2 extends batchjobsch.BatchJobBase implements Database.Batchable<SObject>, Database.Stateful
{
    /*
    Purpose         :   Updates Programs available for outreach on Accounts.  Also updates field Today__c on Account w/ today's date.
                        This batch is also part of a nightly scheduled job.
    
    Create By       :   Nathan Banas (SAP) - 2/9/2011
    
    Last Modified By:   Nathan Banas (Synaptic) 4/21/11
    
    Current Version :    
    
    Revision Log    :   V_1.0 - (NB-2011-02-09) Created code.
                        V_1.1 - (JN 3/22/11) Copied code into new Class file due to corrupt old Class
                        V_1.2 - (NB 3/20/11) Updated API version from 19 to 20.  Added try/catch block around the Outreach Program
                                trim section.  Added null check to each Outreach Program condition prior to trim to ensure no
                                exceptions are being thrown.
                        V_1.3 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                        V_1.4 - Modified By - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        V_1.5 - Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
                        V_1.6 - Modified By - Ajit Surana - 02/23/2015 - CR-20150122-8591 - Updated Finish() method
                        V_1.7 - Modified By - Abhinav Sharma - 07/16/2015 - CR-20150520-8962 - Update start method to include fields in query
                        V_1.8 - Modified By - Mahendra Swarnkar - 12/09/2016 - CR-20161110-10365 - Started the "Batch_ManagePermissionsComponentAccess" batch execution in the final methods
                        V_1.9 - Modified By - Dipesh Gupta - 08/18/2017 - once Batch_Account_OutreachProgs_v2 batch execution completed then after 5 minutes Schedule the batch "Batch_ManagePermissionsComponentAccess
                        V_2.0 - Modified By - Abhinav Sharma - 01/26/2018 - CR-20170420-10865
                        V_2.1 - Modified By - Subhash Garhwal - 07/20/2017 - CR-20180504-12213 - Batch_UpdateCurrentYearFeesOnMembership
                        v_2.2 - Modified By - Victor Hanson - CR-20180720-12460 - adjusted finish() method sysTime
                        V_2.3 - Merged By - Rajeev jain - CR-20180720-12460 - Deployment 
                        V_2.4 - Modified By - Abhinav sharma - CR-20180615-12286- 08/27/2018 - Added Active_ES_Memberships__c
                        V_2.5 - Merged By - Rajeev Jain - Deployment - CR-20150520-8962 - 09/13/2018
                        V_2.6 - Modified By - Victor Hanson - 09/10/2018 - CR-20180803-12480 - Added reference to Zendesk Support field
                        V_2.7 - Merged By - Rajeev Jain - CR-20180803-12480 - Deployment. 
                        V_2.8 - Merged By - Rajeev jain - 09/25/2018 - CR-20170812-11145 Call - Batch_ActiveInstitutionStaffAssignment
                        V_2.9 - Modified By - Colin McGloin - 10/04/2019 - CR-20190826-13285 - Added in Batch_NightlyMembershipStatusCheck batch schedule
                        V_3.0 - Modified By - Victor Hanson - 12/03/2019 - CR-20191203-13544 - updated name of Batch_NightlyMembershipStatusCheck job
                        V_3.1 - Modified By - Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Commented the Academies_Memberships__c field
			V_3.2 - Modified By - Mahendra Swarnkar - 02/05/2021 - CR-20200724-14362 - Scheculed the shcedulers 
												   a) Intranet_Birthdays 
												   b) Schedule_Batch_Revenue
												   c) Schedule_Batch_UpdateMilestoneRevenue
                            									   d) Scheduler_Batch_Cleanup
                            									   e) Sched_UpdateContactFieldProtocoled 
			V_3.3 - Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410
    			V_3.4 - Modified By - Mahendra Swarnkar - CR-20210316-15001 - 06/29/2021 - Business Lines 'YV' and 'ES'  
                        V_3.5 - Modified By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes

    Code Coverage as of 2/9/2011: 99%
    Code Coverage as of 4/21/2011: 96% (Loss in coverage is due to the addition of the try/catch surrounding the trim section.)
    */
    
    public string Query = null;
    
    date TodaysDate = system.today();
    
    global string debuglog = '';
    Integer batchnum = 0;
    Integer totalprocessed = 0;
    public Integer totalErrors = 0;
    
    //Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    //global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_Account_OutreachProgs_v2 ()
    {
        debugLogStr = '';
        
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx)
    {
        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email 
                          FROM AsyncApexJob 
                          WHERE id = :ctx.getJobId()];
        System.debug('### Current Query: ' + Query);
        Util.BypassAllTriggers  = true;
        if(Query == null)
        {
            Query = Label.Batch_Account_OutreachProgs_v2_Query;
        }
        System.debug('### Executing Batch for Query: ' + Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext ctx, list<Sobject> scope)
    {
        Util.IsBatch = true;
        list<Account> recordList = (list<Account>)scope;
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        // get a map of all institutions
        Map<Id, Account> acctMap = new Map<Id, Account>();
        for (Account acct : recordList) acctMap.put(acct.Id, acct);
        
        //Added Check for Business Lines 'YV' and 'ES' - CR-20210316-15001 - Mahendra Swarnkar - 06/29/2021
        List<String> progAcronymList = new List<String> { 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN', 'RY', 'YV', 'ES' };
        
        // get ALL memberships associated with those institutions
        List<Membership__c> membershipList = [SELECT id, Account_Name__c, Program__r.Business_Line__c, Prospect_Status__c, Membership_Status__c,
                                              Program__c, Program__r.Program_Acronym__c, Renewal_Unit_Count__c, Program__r.Integration_Support__c
                                              FROM Membership__c 
                                              WHERE Account_Name__c IN :acctMap.keySet() AND Program__r.Business_line__c IN :progAcronymList];
        
        Map<Id, List<Membership__c>> acctToMembershipsMap = new Map<Id, List<Membership__c>>();
        
        for (Membership__c mem : membershipList) {
            List<Membership__c> tempMemList = acctToMembershipsMap.get(mem.Account_Name__c);
            if (tempMemList == null) tempMemList = new List<Membership__c>();
            tempMemList.add(mem);
            acctToMembershipsMap.put(mem.Account_Name__c, tempMemList);
        }
        
        for(Account a : acctMap.values())
        {
            // Set Today's Date on Account
            a.Today__c = TodaysDate;
            
            // Zero out the 4 kinds of Membership Counts on this Account & the 3 kinds of Membership Program Acronyms
            a.Core_Memberships__c = 0;
            a.BI_Memberships__c = 0;
            //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492
           // a.Academies_Memberships__c = 0;
            a.Core_Programs_Available_for_Outreach__c = '';
            a.Academy_Programs_Available_for_Outreach__c = '';
            a.BI_Programs_Available_for_Outreach__c = '';
       
            // clear out active membership list
            a.Active_RI_Memberships__c = '';
            a.Active_PT_Memberships__c = '';
            a.Active_TD_Memberships__c = '';
            
            //Added by Abhinav sharma - CR-20180615-12286 - 08/27/2018 - Added Active_ES_Memberships__c
            a.Active_ES_Memberships__c = '';
            
            system.debug('### Processing Account: ' + a);
            system.debug('@@mems:' + acctToMembershipsMap.get(a.Id));
            a = MembershipTriggerHelper.process_membership(a, acctToMembershipsMap.get(a.Id));           
            
            System.debug('### Academy_Programs_Available_for_Outreach__c (untrimmed): ' + a.Academy_Programs_Available_for_Outreach__c);
            System.debug('### BI_Programs_Available_for_Outreach__c (untrimmed): ' + a.BI_Programs_Available_for_Outreach__c);
            System.debug('### Core_Programs_Available_for_Outreach__c (untrimmed): ' + a.Core_Programs_Available_for_Outreach__c);
            
            // Format the Programs Available for Outreach to remove blank spaces and ensure the max length is not exceeded then return the results to account
            try
            {
                if (a.Academy_Programs_Available_for_Outreach__c != null && a.Academy_Programs_Available_for_Outreach__c != '')
                    a.Academy_Programs_Available_for_Outreach__c = 
                        a.Academy_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Academy_Programs_Available_for_Outreach__c.trim().length()));
                if (a.BI_Programs_Available_for_Outreach__c != null && a.BI_Programs_Available_for_Outreach__c != '')
                    a.BI_Programs_Available_for_Outreach__c = 
                        a.BI_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.BI_Programs_Available_for_Outreach__c.trim().length()));
                if (a.Core_Programs_Available_for_Outreach__c != null && a.Core_Programs_Available_for_Outreach__c != '')
                    a.Core_Programs_Available_for_Outreach__c = 
                        a.Core_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Core_Programs_Available_for_Outreach__c.trim().length()));
            }
            catch (exception ex)
            {
                debuglog += 'Trim Exception: ' + a.Name + ' (' + a.Id + ') - ' + ex.getMessage() + '\n';
                debugLogStr += 'Trim Exception: ' + a.Name + ' (' + a.Id + ') - ' + ex.getMessage() + '\n';
            }
            System.debug('### Academy_Programs_Available_for_Outreach__c (trimmed): ' + a.Academy_Programs_Available_for_Outreach__c);
            System.debug('### BI_Programs_Available_for_Outreach__c (trimmed): ' + a.BI_Programs_Available_for_Outreach__c);
            System.debug('### Core_Programs_Available_for_Outreach__c (trimmed): ' + a.Core_Programs_Available_for_Outreach__c);
            totalprocessed++;
        }
        
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
       //Added By Rajeev jain to cover the classes from test class - to perform the partial deployment.
        if(test.isRunningTest())
           debugLogStr = 'Custom Error String to cover some part of class';
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_Account_OutreachProgs_v2', debugLogStr, sfAdminUser[0].Email);
        }
        
        //Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410 - Move Sched_DeleteWebServiceLogs outside ExecuteNextJob check
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = DateTime.now();
        
        //Added By - Ajit Surana - 02/23/2015 - CR-20150122-8591
        //Build the system time of now +60 Seconds to schedule the batch apex.
        Datetime sysTime2;
        sysTime2 = sysTime.addMinutes(10);
        String chron_exp2 = '' + sysTime2.second() + ' ' + sysTime2.minute() + ' ' + sysTime2.hour() + ' ' + sysTime2.day() + ' ' + sysTime2.month() + ' ? ' + sysTime2.year();
        
        //Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410 - Comment ended
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {


            sysTime = sysTime.addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //Scheduler class
            Sched_UpdateAccTeamMemberSharingOppNBB controller = new Sched_UpdateAccTeamMemberSharingOppNBB();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_UpdateAccTeamMemberSharingOppNBB' + sysTime.getTime(),chron_exp,controller);
            
            
            //queueable job that syncs zendesk tickets to cases / case comments
           /* ZendeskService service = new ZendeskService();
            service.syncSinceDate = date.today().addDays(-2);
            QueueableZendeskSync zendeskQueue = new QueueableZendeskSync(service, ZendeskService.SYNC_TYPE_ORGANIZATIONS);*/
            

            
            
            //CommentOut By - Mahendra Swarnkar - CR-20161110-10365 (CR-20200714-14300)
            //Added By - Mahendra Swarnkar - 12/09/2016 - CR-20161110-10365
            //once Batch_Account_OutreachProgs_v2 batch execution completed then after 5 minutes Schedule the batch "Batch_ManagePermissionsComponentAccess"
            //Integer BatchSize_Batch_ManagePermissionsComponentAccess = Integer.valueOf(Label.Batch_Size_Batch_ManagePermissionsComponentAccess);
            //Batch_ManagePermissionsComponentAccess bp = new Batch_ManagePermissionsComponentAccess();
            //System.scheduleBatch(bp, 'Batch_ManagePermissionsComponentAccess'+system.today(), 5, BatchSize_Batch_ManagePermissionsComponentAccess); 
            
            //Added By - Victor Hanson - 03/20/2017 - CR-20170110-10605
            Integer batchSize_Batch_RoyallMembershipUpdate = Integer.valueOf(Label.Batch_Size_Batch_RoyallMembershipUpdate);
            System.scheduleBatch(new Batch_RoyallMembershipUpdate(), 'Batch_RoyallMembershipUpdate'+system.today(), 5, batchSize_Batch_RoyallMembershipUpdate); 
            
            //Query from the custom setting.
            //Get Default values from the Custom settings.  
            User_InActive_Ownership_To_SFAdmin__c userInactiveOwnerShip = User_InActive_Ownership_To_SFAdmin__c.getOrgDefaults();
            
            //V_1.9_Added By - Dipesh Gupta- 08/18/2017 - CR-20170412-10836
            //once Batch_Account_OutreachProgs_v2 batch execution completed then after 5 minutes Schedule the batch "Batch_ManagePermissionsComponentAccess"  
            Batch_UpdateInActiveOwnershipToSFAdmin bp1 = new Batch_UpdateInActiveOwnershipToSFAdmin();
            System.scheduleBatch(bp1, 'Batch_UpdateInActiveOwnershipToSFAdmin'+system.today(), 5, Integer.ValueOf(userInactiveOwnerShip.Batch_Size__c));
            
            //V_1.10 - Added By Abhinav Sharma - 01/26/2018 - CR-20170420-10865
            Batch_SendEmailToRequesterAboutCase bp2 = new Batch_SendEmailToRequesterAboutCase();
            System.scheduleBatch(bp2, 'Batch_SendEmailToRequesterAboutCase'+ system.today(), 5, 10);
            
            //V_1.11 - Added By Subhash - 06/26/2018 - CR-20180502-12199
            /*Batch_SubscriptionsRenewalOwner bp3 = new Batch_SubscriptionsRenewalOwner();
            System.scheduleBatch(bp3, 'Batch_SubscriptionsRenewalOwner'+system.today(), 5, Integer.ValueOf(Label.Batch_Size_Batch_SubscriptionsRenewalOwner));*/
            
            //Added By Subhash Garhwal - 07/20/2017 - CR-20180504-12213 - Batch_UpdateCurrentYearFeesOnMembership
            Batch_UpdateCurrentYearFeesOnMembership batchMembership = new Batch_UpdateCurrentYearFeesOnMembership();
            System.scheduleBatch(batchMembership, 'Batch_UpdateCurrentYearFeesOnMembership'+ system.today(), 5, 20);
            
            
            //V_1.11 - Added By - Victor Hanson - 09/10/2018 - CR-20180803-12480
           // system.enqueueJob(zendeskQueue);
            
            //V_1.11 - Added By - Victor Hanson - 09/10/2018 - CR-20180803-12480
            //batch job that syncs project roles to Zendesk
            database.executeBatch(new Batch_SyncZendeskUserRoles(), 10);
            
            //V_1.11 - Added By - Neha Sharma - 23/10/2021- CR-20210301-14957
            //batch job that syncs ZendeskMPOCRoles to Zendesk
            database.executeBatch(new Batch_SyncZendeskMPOCRoles(), 10);
            
            //check for the test Run to avoid the multiple batches execution error.
            if(test.isRunningTest())
                return;
            
            //V_1.11 - Added By Rajeev Jain - 09/10/2018 - CR-20170812-11145 
            Batch_ActiveInstitutionStaffAssignment bP3 = new Batch_ActiveInstitutionStaffAssignment();
            System.scheduleBatch(bP3, 'Batch_ActiveInstitutionStaffAssignment'+Date.today(), 10, 50);

            //V_1.14 - Added by Colin McGloin - 10/04/2019 - CR-20190826-13285
            //V_1.15 - Modified by Victor Hanson - 12/03/2019 - CR-20191203-13544 updated name of scheduled batch job
            Batch_NightlyMembershipStatusCheck bMSC = new Batch_NightlyMembershipStatusCheck();
            System.scheduleBatch(bMSC, 'Batch_NightlyMembershipStatusCheck'+Date.today(), 20, 50);
            
            //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Starts from here
            //V_1.22 - Modified By - MAhendra Swarnkar - 02/05/2021 - CR-20200724-14362 - Starts from here
            /*Intranet_Birthdays sIB = new Intranet_Birthdays();
            System.schedule('Intranet_Birthdays' + sysTime2.getTime(), chron_exp2, sIB);*/
            //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Ends from here

            Schedule_Batch_Revenue sNBR = new Schedule_Batch_Revenue();
            System.schedule('Schedule_Batch_Revenue' + sysTime2.getTime(), chron_exp2, sNBR);
            
            Schedule_Batch_UpdateMilestoneRevenue sBUM = new Schedule_Batch_UpdateMilestoneRevenue();
            System.schedule('Schedule_Batch_UpdateMilestoneRevenue' + sysTime2.getTime(), chron_exp2, sBUM);
            
            Scheduler_Batch_Cleanup sBU = new Scheduler_Batch_Cleanup();
            System.schedule('Scheduler_Batch_Cleanup' + sysTime2.getTime(), chron_exp2, sBU);
            
            Sched_UpdateContactFieldProtocoled sUCFP = new Sched_UpdateContactFieldProtocoled();
            System.schedule('Sched_UpdateContactFieldProtocoled' + sysTime2.getTime(), chron_exp2, sUCFP);
            
            //V_1.22 - Modified By - MAhendra Swarnkar - 02/05/2021 - CR-20200724-14362 - Ends here
            

        }
        
        //Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410 - Move Sched_DeleteWebServiceLogs outside ExecuteNextJob check
        //Added By - Ajit Surana - 02/23/2015 - CR-20150122-8591
        //Scheduler class
        Sched_DeleteWebServiceLogs controller2 = new Sched_DeleteWebServiceLogs();
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Sched_DeleteWebServiceLogs' + sysTime2.getTime(),chron_exp2,controller2);
        //Modified By - Neha Sharma - 04/20/2021 - CR-20191014-13410 - Comment ended
        
    }
}