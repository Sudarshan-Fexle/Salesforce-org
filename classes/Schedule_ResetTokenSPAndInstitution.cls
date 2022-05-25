/**
*  Description     :    Schedule class to run the Batch_ResetSiteTokenOnSPAndInstitution Every year
*
*  Created By      :    Dipesh Gupta     
* 
*  Created Date    :    06/26/2019   
* 
*  Revision Logs   :    V_1.0 - Created
*                      
**/
global class Schedule_ResetTokenSPAndInstitution implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        //Executing Batch
        Database.executeBatch(new Batch_ResetSiteTokenOnSPAndInstitution(), 50);
    } 
}