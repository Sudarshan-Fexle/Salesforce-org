/*
    Purpose            :    Scheduler class to schedule "Batch_UpdateRIMemberHealthSnapshotFields" batch job. Once 
							"Batch_MeetingUtilizations" batch job got executed completely and successfully.
    
    Created By         :    Abhinav Sharma
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Abhinav Sharma - CR-20160114-9516 - 02/29/2016
*/
global class Sched_UpdateRIMemberHealthSnapshotFields implements Schedulable {
	
    //Execute Method
    global void execute(SchedulableContext ctx) {
    	Batch_UpdateRIMemberHealthSnapshotFields batchCon = new Batch_UpdateRIMemberHealthSnapshotFields();
        ID batchprocessid = Database.executeBatch(batchCon, Integer.valueOf(System.Label.BATCH_SIZE_Batch_UpdateRIMemberHealthSnapshotFields));
	}   
}