/**
*  Description     :    Schedule class to run the Batch_UpdateEnrollmentTypeMemembership 
*
*  Created By      :    Dipesh Gupta      
* 
*  Created Date    :    01/27/2020   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20190718-13214
*                      
**/
global class Sched_Batch_UpdateEnrollmentTypeMem implements Schedulable {
    
    //Execute Method
    global void execute(SchedulableContext ctx){
        
        //Getting Job Size
        Integer batchJobSize = Integer.valueOf(System.Label.Batch_Job_Size);
        //Just Instantiate Batch Class
        Batch_UpdateEnrollmentTypeMemembership batch = new Batch_UpdateEnrollmentTypeMemembership();
        Database.executeBatch(batch, batchJobSize);
    }
    
}