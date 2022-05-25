/**
*  Description     :   This batch class is run after 15 minutes when standard contract is created.
*
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   03/02/2020
*
*  Current Version :   v1.0
*       
*  Revision Log    :   V_1.0 Created               
**/
global class Scheduler_BatchAutomatedProjAndRelated implements Schedulable 
{
    global Set<Id> setOfContractIds = new Set<Id>();
    
    global Scheduler_BatchAutomatedProjAndRelated(Set<Id> contractIds)
    {
        setOfContractIds = contractIds;   
    }
    
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_AutomatedProjectAndRelated(setOfContractIds));
    }
    
    //Schedule the Apex Job after n Minutes 
    public static void scheduleAfterMinutes(Integer minutes,Set<Id> contractIds) 
    {
        CoreUtilities.unscheduleASpecificJobOfCompletedType(System.Label.Schedule_Job_Name_For_Abort_Job);
        
        //Reschedule the Job after n minutes
        DateTime sysTime = dateTime.now().addMinutes(minutes);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        Scheduler_BatchAutomatedProjAndRelated sched_Job = new Scheduler_BatchAutomatedProjAndRelated(contractIds);
        
        System.schedule(System.Label.Schedule_Job_Name_For_Contract + String.valueOf(Math.random()), chron_exp, sched_Job);
    }
}