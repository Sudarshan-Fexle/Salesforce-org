/** 
    *  Purpose         :  Helper class for Sched_CatalystRecipientBatchReceived
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    *
    **/
global class Sched_CatalystRecipientBatchReceived Implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {  
        Batch_CatalystRecipientBatchReceived catalystRB = new Batch_CatalystRecipientBatchReceived();
        database.executeBatch(catalystRB);
    }
}