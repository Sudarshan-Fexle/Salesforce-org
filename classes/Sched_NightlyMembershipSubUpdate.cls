global class Sched_NightlyMembershipSubUpdate implements Schedulable {

    global Integer batchsize = 50;  // DAF was 50 
    public Id batchprocessid;
    
    global Sched_NightlyMembershipSubUpdate() {
    }

    global void execute(SchedulableContext ctx) {

        //Call Batch with specified batch size
        Batch_NightlyMembershipSubUpdate batch = new Batch_NightlyMembershipSubUpdate();
        
        //Execute Batch
        batchprocessid = Database.executeBatch(batch, batchsize);
        
    }
}