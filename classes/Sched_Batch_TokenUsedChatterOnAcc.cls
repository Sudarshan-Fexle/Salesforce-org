/*
    Purpose         :   Schedular to run the batch class (Batch_TokenUsedChatterOnAccount), hourly. 
    
    Create By       :   Mahendra Swarnkar
    
    Created Date    : 	07/29/2020
    
    Revision Log    :   V1.0 - Created - 07/29/2020 - CR-20200415-13948
                    	

*/
global class Sched_Batch_TokenUsedChatterOnAcc implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        Batch_TokenUsedChatterOnAccount b = new Batch_TokenUsedChatterOnAccount();
        Database.executeBatch(b);
    }
}