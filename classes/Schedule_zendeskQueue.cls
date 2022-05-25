/**
*  Description     :    Schedule class to run the hourly basis
*
*  Created By      :    Neha Sharma      
* 
*  Created Date    :    23/10/2021   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20210301-14957
*                      
**/
global class Schedule_zendeskQueue implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        
        ZendeskService service = new ZendeskService();
        service.syncSinceDate = date.today().addDays(-2);
        QueueableZendeskSync zendeskQueue = new QueueableZendeskSync(service, ZendeskService.SYNC_TYPE_ORGANIZATIONS);
        if(test.isRunningTest())
                return;
        system.enqueueJob(zendeskQueue);
    }
    
}