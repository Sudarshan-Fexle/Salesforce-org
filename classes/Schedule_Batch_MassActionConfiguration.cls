/**
*  Description     :    Schedule class to run the Nightly  Batch 
*                       Calls Batch_MassActionConfiguration daily at night 12 AM.
*
*  Created By      :    Saurabh Kumar      
* 
*  Created Date    :    11/19/2020   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20201117-14698
*                      
**/
global class Schedule_Batch_MassActionConfiguration implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        
        //Just Instantiate Batch Class
        Batch_MassActionConfiguration batch = new Batch_MassActionConfiguration();
        Database.executeBatch(batch, 1);
    }
    
}