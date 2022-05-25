/**
 *  Description     :  Scheduler class to execute the  populateSubscriptionFieldsOnMembershipFuture of ContractIntegratedAccountsTriggerHelper class
 *
 *  Created By      :  Mahendra Swarnkar
 *
 *  Created Date    :  01/09/2021
 *
 *  Revision Logs   :   V_1.0 - Created - Mahendra Swarnkar - CR-20210831-15398
 *
 **/
global class Sched_populateSubFieldsOnMembership implements Schedulable {
    
    public Set<Id> setAllStdContractIds;
    public Boolean createMembership;
    public Set<Id> setCIAIds;
    //Constructor
    public sched_populateSubFieldsOnMembership (Set<Id> setAllStdContractIds, Set<Id> setCIAIds, Boolean createMembership){
        this.setAllStdContractIds = setAllStdContractIds;
        this.createMembership = createMembership;
        this.setCIAIds = setCIAIds;
    }
    
    global void execute(SchedulableContext ctx) {
        if(this.createMembership){
            ContractIntegratedAccountsTriggerHelper.createMembershipsFuture(setCIAIds);
        }else{
        	ContractIntegratedAccountsTriggerHelper.populateSubscriptionFieldsOnMembershipFuture(setAllStdContractIds);
	}
    }
    
    /**
     *  @description        :   Schedules the job sched_populateSubFieldsOnMembership
     *  
     *  @args               :   Set<Id> 
     *
     *  @return             :   void
     * 
     *  @Revision Logs      :   V1.1 - 03/08/2018 - Created - CR-20210831-15398
     *
    **/
    
    public static void schedule_populateSubFieldsOnMembership(Set<Id> setAllStdContractIds, Set<Id> setCIAIds, Boolean createMembership){
        
        //Schedule the job
        DateTime sysTime = DateTime.now();
        if(createMembership){
            sysTime = sysTime.addSeconds(10);
        }
        else{
            sysTime = sysTime.addSeconds(5);
        }
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        sched_populateSubFieldsOnMembership scheduleJob = new sched_populateSubFieldsOnMembership(setAllStdContractIds, setCIAIds, createMembership);
        System.schedule('sched_populateSubFieldsOnMembership' + sysTime.getTime(),chron_exp, scheduleJob);
    }
}