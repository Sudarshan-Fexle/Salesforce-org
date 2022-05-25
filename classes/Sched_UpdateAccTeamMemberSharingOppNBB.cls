/**
 *  Description     :   Scheduler class to schedule Batch_UpdateAccTeamMemberSharingOppNBB batch
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   12/16/2013
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20130517-3034
 *                      V_1.1 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
 * 						V1_2 - modifyBy - Abhinav Sharma - 04/04/2018 - CR-20180404-12147 - Change the batch size from the default to 50.
 **/
global class Sched_UpdateAccTeamMemberSharingOppNBB implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
    
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        Batch_UpdateAccTeamMemberSharingOppNBB batch = new Batch_UpdateAccTeamMemberSharingOppNBB();
        batch.ExecuteNextJob = true;
        
        //Changing the Batch size -  from default to 50  
        //Execute Batch
        Id batchProcessId = Database.executeBatch(batch, 50);
        
        if (batchProcessId != null)
            Util.ScheduleHasRun = true;
    }       
}