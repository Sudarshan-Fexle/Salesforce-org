global class Sched_UpdateContactFieldProtocoled implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        Set<Id> conId = new Set<Id>();
        Batch_UpdateContactFieldProtocoled bc = new Batch_UpdateContactFieldProtocoled(1,conId);
        Database.executeBatch(bc);
    }
}