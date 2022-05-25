/**
*  Purpose      :   Class to periodically check whether run all tests has been completed 
					or not and accordingly, to do post steps, once completed.
*  Created By   :   Abhinav Sharma
**/
global with sharing class BatchExecuteRunAllTests implements Database.Batchable<sObject>, Database.Stateful
{
    global String query;
    global Boolean errorOnly;
    global Boolean displayProgressOnUI;
    global List<ApexClass> totalTestClasses;
    
    global BatchExecuteRunAllTests()
    {
        if(errorOnly == null) 
        {
            errorOnly = true;
        }
        
        if(displayProgressOnUI == null) 
        {
            displayProgressOnUI = false;
        }
        totalTestClasses = new List<ApexClass>();
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(query == null) 
        {
            Set<Id> testclassesIds = DatabaseUtilities.extractTestClassesIds();
            
            if(testclassesIds.size() > 0) 
            {
                query = ApexClassQueryBuilder.buildDynamicApexClassQuery(testclassesIds);
            }
            else 
            {
                throw new customException(System.Label.No_Test_Class_To_Run);
            }
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<ApexClass> testClasses)
    {
        if (testClasses.size() > 0) 
        {
            totalTestClasses.addAll(testClasses);
        }        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        if(totalTestClasses.size() > 0) 
        {
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            for (ApexClass cls : totalTestClasses) 
            {
                queueItems.add(new ApexTestQueueItem(ApexClassId=cls.Id));
            }
            if (!Test.isRunningTest()) 
            {
                insert queueItems;
                if(queueItems.size() > 0) 
                {
                    String jobId = queueItems[0].Id;
                    List<ApexTestQueueItem> items = ApexTestQueueItemQueryBuilder.returnRunTestsItemsRelatedToJob(jobId);
                    if(items.size() > 0) 
                    {
                        String day = string.valueOf(system.now().day());
                        String month = string.valueOf(system.now().month());
                        String hour = string.valueOf(system.now().hour());
                        String minute = string.valueOf(system.now().minute() + 1);
                        String second = string.valueOf(system.now().second());
                        String year = string.valueOf(system.now().year());
                        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                        Scheduler_SummarizeRunAllTestsResults job = new Scheduler_SummarizeRunAllTestsResults(items[0].ParentJobId, '', errorOnly, displayProgressOnUI);
                        CoreUtilities.unscheduleJobsWithoutNextFireDate();
                        System.schedule(System.Label.Run_All_Test_Scheduler_Name, strSchedule, job);     
                    }
                }
            }    
        }
    }
}