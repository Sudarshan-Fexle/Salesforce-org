/**
 *  Purpose     	:      	Scheduler class to Schedule job for the batch Batch_ShiftAccountStatus
 *
 *  Created By      :      	Subhash Garhwal
 *
 *  Created Date    :      	07-08-2016
 *
 *  Revision Logs   :		V1.0 - Created
 *							V_1.1 - Moved - 9/20/2016 - Subhash Garhwal - CR-20160817-10134 - Moved class from Royall Instance
 *							
 **/
global without sharing class Scheduler_Batch_RoyallShiftAccountStatus implements Schedulable {
	
	//execute method of schedulable interface
	global void execute(SchedulableContext sc) {
    	 
    	//Batch initailization and this batch is used to capture the forecast variences
		Batch_RoyallShiftAccountStatus batch = new Batch_RoyallShiftAccountStatus();
		
		//execute Batch 
		Database.executeBatch(batch);
  
       }
}