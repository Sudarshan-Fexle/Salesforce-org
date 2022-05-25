/*
    Purpose         :   Schedular class for Batch_MembershipSubscriptions class.
                
    Create By       :   
    
    Created Date    :   3/14/2013
    
    Revision Log    :   V1.0 Created
						v1.1 - Abhinav Sharma - 10/15/2015 - CR-20140407-4977 - Updated the batch size from 1 to 30
    
*/
global class Sched_MembershipSubscriptions implements Schedulable {
	global void execute(SchedulableContext ctx) {
        
        //Executing batch job with batch size of 30
        //Previosuly batch size was 1 and we have to updated to 30 in place of 50
        //because in case of batch size of 50, it can results as an error "Too many DML rows: 10001" due to large records count to update
        Batch_MembershipSubscriptions memberSubscriptionsBatch = new Batch_MembershipSubscriptions();
        ID batchprocessid = Database.executeBatch(memberSubscriptionsBatch,30);
	}   
}