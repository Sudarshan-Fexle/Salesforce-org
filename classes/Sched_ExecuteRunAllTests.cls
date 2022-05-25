global class Sched_ExecuteRunAllTests implements Schedulable 
{
	global void execute(SchedulableContext SC) 
    {
        //Executing Batch class to Run All Tests and then to generate reportings
        BatchExecuteRunAllTests b = new BatchExecuteRunAllTests();
		Database.executeBatch(b);
	}   
}