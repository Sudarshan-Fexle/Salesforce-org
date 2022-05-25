global class Sched_Event_UpdateProgramAbbreviation implements Schedulable {

   global void execute(SchedulableContext ctx) {
      
       //Execute batch for tasks and events
       Batch_Event_UpdateProgramAbbreviation batch = new Batch_Event_UpdateProgramAbbreviation();
       batch.isEvent = true;
       Database.executeBatch(batch);
       
       batch.isEvent = false;
       Database.executeBatch(batch);
   }   
}