global class Schedule_Batch_UpdateMilestoneRevenue implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    	Batch_UpdateMilestoneRevenue batchObj = new Batch_UpdateMilestoneRevenue(); //ur batch class
      	database.executebatch(batchObj,200);
    }
}