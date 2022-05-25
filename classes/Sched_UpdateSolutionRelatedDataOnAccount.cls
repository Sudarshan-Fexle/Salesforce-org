/**
 *  Purpose         :   This Schedule class is to replicate the solution data on the Account from the solution Staff Assignment 
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   03/22/2016  
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150908-9224
 *                      
 **/ 
global class Sched_UpdateSolutionRelatedDataOnAccount implements Schedulable {
	
    //Execute method
    global void execute(SchedulableContext sc) {
    	
        Batch_UpdateSolutionRelatedDataOnAccount batchCon = new Batch_UpdateSolutionRelatedDataOnAccount();
        ID batchprocessid = Database.executeBatch(batchCon, Integer.valueOf(System.Label.BATCH_SIZE_Batch_UpdateSolutionRelatedDataOnAccount));       
    }
}