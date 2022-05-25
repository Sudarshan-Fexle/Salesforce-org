/**
 *  Description     :  Scheduler class to execute the updateOptOutType method
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  08/07/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal 
 *	
 *
 **/

global class Sched_UpdateOptOutType implements Schedulable {
    
    public Set<Id> setProposalIds;
    
    //Constructor
    public Sched_UpdateOptOutType(Set<Id> setProposalIds) {
    
        this.setProposalIds = setProposalIds;
        
    }
    //Execute method to process
    global void execute(SchedulableContext ctx) {
        
        try{
            SBQQ_QuoteLineTriggerHelper.updateOptOutType(setProposalIds);
        }catch(Exception e){
            
        }
    }

}