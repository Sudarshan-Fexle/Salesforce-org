global class Sched_MembershipNextActivityDate implements Schedulable {
   global void execute(SchedulableContext ctx) 
	{
        Batch_MembershipNextActivityDate membershipBatch = new Batch_MembershipNextActivityDate(null);
        ID batchprocessid = Database.executeBatch(membershipBatch,20);
	}   

}