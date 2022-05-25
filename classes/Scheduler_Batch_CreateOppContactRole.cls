/**
 *  Description     :   Schedule class to run the Batch_CreateOppContactRole batch daily
 *
 *  Created By      :   Mahindra
 *
 *  Created Date    :   02/21/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Mahindra - CR-20200121-13645
 *                      
 **/
global class Scheduler_Batch_CreateOppContactRole implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        
        //Just Instantiate Batch Class
        Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(1);
        Database.executeBatch(batch,200);
    }
    
}