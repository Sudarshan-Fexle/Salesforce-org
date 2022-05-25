/**
  *   Description    :  Scheduler call to call Queqble job
  *              
  *   
  *   Created by    :  Mahendra Swarnkar
  * 
  *   Created Date  :  08/21/2019
  *   
  *   Revision Log  :  V1.0 Created - CR-12685 (Created as per the production validation Error/exception).
  *             Coverage - 84%
 **/
global class Sched_UpdateWebProgramAccessQueqbleJob implements Schedulable {
  
    //Variables
    public Set<Id> setAccountIds;
    public Set<Id> setAccountIdsOnInactiveMembership;
    
    //Constructor
    public Sched_UpdateWebProgramAccessQueqbleJob() {
        setAccountIds = new Set<Id>();
        setAccountIdsOnInactiveMembership = new Set<Id>();
    }
    
    global void execute(SchedulableContext ctx) {
        
        if(setAccountIds.size() > 0 || setAccountIdsOnInactiveMembership.Size() > 0) {
            
            Sched_UpdateWebProgramAccessOnAccount sch1 = new Sched_UpdateWebProgramAccessOnAccount();
            sch1.setAccountIds = setAccountIds;
            sch1.setAccountIdsOnInactiveMembership = setAccountIdsOnInactiveMembership;
            System.enqueueJob(sch1);
        }
    }
}