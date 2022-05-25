/**
 *	Purpose			:	This class is used to schedule the intranet Utilization records whenever Unable to lock error will thrown on "Utilization" records insertion
 *							This job is scheduled from the "createIntranetUtilizationRecord()" method(future) of "IntranetUtilizationHelper" class. 
 *
 *	Created By		:	Mahendra Swarnkar
 *
 *	Created Date	:	07/07/2017
 *
 *	Revision Logs	:	V_1.0 - Created 
 *
 **/ 
global class Sched_UtilizationInsert implements Schedulable{
	
    //variable to hold the utilization record to be inserted
    public Intranet_Utilization__c intranetUtilization;
    
    //Execute Schedular
    global void execute(SchedulableContext ctx) {
        
        Sched_UtilizationInsert sched = new Sched_UtilizationInsert();
        	
        //Assign the value for intranetUtilization record
        sched.intranetUtilization = intranetUtilization;
        
        //Build the system time of now + 1 minute to schedule the batch that will copy the dashboard html/images.
        Datetime sysTime = System.now();
        sysTime = sysTime.addMinutes(1);
        String CRON_EXP = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
        try{
            
            //Insert intranetUtilization record
            if(intranetUtilization != null) 
            	insert intranetUtilization;
            
        }catch(Exception ex){
            
            //Check for the Error
            if(ex.getMessage().contains(system.Label.ERROR_UNABLE_TO_LOCK_ROW))
                
                //schedule the scheduler
                Id jobId = System.schedule(IntranetUtilizationHelper.SCHEDULER_STATIC_NAME +((math.random()) * 10000), CRON_EXP, sched);
            else
                throw new CustomException(ex.getMessage()+' Cause:'+ex.getCause()+ 'Line NO: '+ex.getLineNumber() +'StackTrace: '+ ex.getStackTraceString());
        }
    }
}