/**
*  Description     :    Schedule class to run the Nightly Revenue Batch 
*                       Calls Batch_Revenue daily at night 11:00 PM EST
*
*  Created By      :    Colin McGloin      
* 
*  Created Date    :    03/06/2019   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20180918-12607
*                      
**/
global class Schedule_Batch_Revenue implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        
        //Just Instantiate Batch Class
        Batch_Revenue batch = new Batch_Revenue();
        Database.executeBatch(batch, 200);
    }
    
}