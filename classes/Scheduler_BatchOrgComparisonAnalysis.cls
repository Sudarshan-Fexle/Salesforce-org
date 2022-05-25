/*
*   Description     :   Scheduler Class to Schedule/to pull the Org changes.
*
*   Created by      :   Mahendra Swarnkar
*
*   Created Date    :   1/27/2020
* 
*   Revision Log    :   v1.0                
*/
global class Scheduler_BatchOrgComparisonAnalysis implements Schedulable, Database.Stateful, Database.AllowsCallouts {
    
    //Map to ,Hold the index (starting from 1) with org comparision record 
    public Integer currentIndex = 0;
    
    //Jobs Status values
    public static final Set<String> releaseSatus = new Set<String>{'Deployed', 'Cancelled'};
        
	public Map<Integer, OrgComparisionWrapper> mapOrgComparisionWrappers;
    
    //Jobs Status values
    public static final Set<String> setJosStatus = new Set<String>{'WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED', 'BLOCKED','PAUSED_BLOCKED', 'Holding', 'Queued', 'Preparing', 'Processing'};
        
	//Map to ,Hold the index (starting from 1) with org comparision record 
	public Static Map<Integer, OrgComparisionWrapper> mapOrgComparisionWrappersAll {
        set;
        get 
        {
            if(mapOrgComparisionWrappersAll == null) 
            {
                //Map to ,Hold the index (starting from 1) with org comparision record 
                mapOrgComparisionWrappersAll = new Map<Integer, OrgComparisionWrapper>();
                
                Integer index = 1;
                for(Org_Comparision__c orgComp : [Select Id, Status__c, Component_Types__c, User_Filter__c, Create_Additive_Mods__c, Create_destructive_mods__c,
                                                  Compare_between_last_modified_dates__c, Save_Mods_To_Different_Org__c, Change_Request__c,
                                                  Created_Date_Bar__c, Last_Modified_Date_Bar__c, Last_Modified_Date_End_Bar__c,
                                                  Save_Mods_To__c, Save_Mods_To__r.Refresh_Token__c,Save_Mods_To__r.Org_type__c,  
                                                  Source_of_Truth__c, Source_of_Truth__r.Refresh_Token__c, Source_of_Truth__r.Org_type__c,
                                                  Comparison_Org__c, Comparison_Org__r.Refresh_Token__c, Comparison_Org__r.Org_type__c,
                                                  Release__c, Release__r.Start_Date__c, Release__r.Ready_for_Org_Comparison__c, Release__r.Last_Org_Comparision_Sync__c,
                                                  Comparison_Org__r.Sandbox_Refresh_Date__c
                                                  From Org_Comparision__c 
                                                  Where (Release__r.Start_Date__c != null AND Release__r.Ready_for_Org_Comparison__c = true AND Release__r.Status__c NOT IN : releaseSatus)])
                {
                    //Check for release record if eligible to fetch the values
                    if(orgComp.Release__c != null && orgComp.Release__r.Start_Date__c != null 
                       && orgComp.Release__r.Ready_for_Org_Comparison__c == true) 
                    {
                        DateTime todayDateTime = system.now();
                        DateTime endDate = todayDateTime.addDays(1); 
                        DateTime startDate = todayDateTime.addDays(-1);
                        
                        if(orgComp.Release__r.Last_Org_Comparision_Sync__c == null)
                            startDate = orgComp.Release__r.Start_Date__c;
                        else 
                        {
                            if(orgComp.Release__r.Last_Org_Comparision_Sync__c != null) 
                            {
                                startDate = orgComp.Release__r.Last_Org_Comparision_Sync__c;
                            }
                        }
                        if(orgComp.Last_Modified_Date_Bar__c != null)
                        {
                            orgComp.Created_Date_Bar__c = orgComp.Last_Modified_Date_Bar__c;
                        }
                        
                        //Get Wrapper Instance
                        OrgComparisionWrapper orgCompWrapper = OrgComparisionUtility.createOrgComparisionWrapperInstance(orgComp, index);
                        
                        if(orgCompWrapper != null ) 
                        {
                            orgCompWrapper.auditStartDateTime = String.valueOf(startDate);
                            orgCompWrapper.auditEndDateTime = String.valueOf(endDate);
                            orgCompWrapper.lastModifiedBarier = startDate.format();
                            orgCompWrapper.lastModifiedEndBar = endDate.format();
                            mapOrgComparisionWrappersAll.put(index, orgCompWrapper);	
                        }
                        index ++;
                    }                 
                }
            }
            return mapOrgComparisionWrappersAll;
        }                                                             
    }
    
    global void execute(SchedulableContext sc) 
    {
        List<AsyncApexJob> listQueueableJobs = new List<AsyncApexJob>();
        listQueueableJobs = [SELECT Id  
                             FROM AsyncApexJob 
                             WHERE Status IN: setJosStatus 
                             AND ApexClass.Name = 'Scheduler_BatchOrgComparisonAnalysis' AND JobType = 'Queueable'];
        List<CronTrigger> listCron = new List<CronTrigger>();
        listCron = [SELECT Id, State, NextFireTime, CronJobDetailId, CronJobDetail.Name  
                    FROM CronTrigger 
                    WHERE State IN: setJosStatus AND CronJobDetail.Name = '%Scheduler_BatchOrgComparisonAnalysis%'];
        if(currentIndex == null || currentIndex == 0)
        {
            mapOrgComparisionWrappers = mapOrgComparisionWrappersAll;
            currentIndex = 1;
        }
        if(listCron.size() == 0 && (listQueueableJobs.size() == 0 
                                    && (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0)) 
        {
            if(mapOrgComparisionWrappers != null && mapOrgComparisionWrappers.size() > 0 
               && mapOrgComparisionWrappers.containsKey(currentIndex) 
               && mapOrgComparisionWrappers.get(currentIndex) != null 
               && mapOrgComparisionWrappers.get(currentIndex).OrgComparisionStatus != 'Complete') 
            {
                Queuable_BatchOrgComparisonAnalysis queueJob = new Queuable_BatchOrgComparisonAnalysis();        
                queueJob.mapOrgComparisionWrappers = mapOrgComparisionWrappers;
                queueJob.currentIndex = currentIndex;
                 System.enqueueJob(queueJob);
            } else 
            {
                currentIndex ++;
                scheduleAfterMinutes(1, mapOrgComparisionWrappers, currentIndex);
            }
        } 
        else 
        {
            scheduleAfterMinutes(15, mapOrgComparisionWrappers, currentIndex);
        }
    }
    
    //Schedule the Apex Job after n Minutes 
    public static void scheduleAfterMinutes (Integer minutes, Map<Integer, OrgComparisionWrapper> mapOrgComparisionWrappers, Integer currentIndex) {
        
        //Clear all the completed Jobs
        List<CronTrigger> jobsToAbort = [select Id from CronTrigger where CronJobDetail.JobType = '7' AND State IN ('COMPLETE', 'DELETED') AND CronJobDetail.Name like 'Scheduler_BatchOrgComparisonAnalysis%' Order BY CreatedDate Desc limit 149];
        for (CronTrigger job : jobsToAbort) 
        { 
            System.abortJob(job.Id); 
        }
        
        //Reschedule the Job after n minutes
        DateTime sysTime = dateTime.now().addMinutes(minutes);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Scheduler_BatchOrgComparisonAnalysis sched_Job = new Scheduler_BatchOrgComparisonAnalysis();
        if(mapOrgComparisionWrappers != null)
        {
            sched_Job.mapOrgComparisionWrappers = mapOrgComparisionWrappers;
            sched_Job.currentIndex = currentIndex;
        }
        System.schedule('Scheduler_BatchOrgComparisonAnalysis' + String.valueOf(Math.random()), chron_exp, sched_Job);
    } 
}