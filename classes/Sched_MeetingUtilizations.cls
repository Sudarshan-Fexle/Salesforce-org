global class Sched_MeetingUtilizations implements Schedulable {
   global void execute(SchedulableContext ctx) 
	{
        Batch_MeetingUtilizations meetingBatch = new Batch_MeetingUtilizations();
        ID batchprocessid = Database.executeBatch(meetingBatch,200);
	}   

}