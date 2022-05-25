/**
  *   Description    :  This class is do the following:-
  *              1) update the Account - web program Access code based on the membership status change
  *              2) start a batch job to expire all existing Site Tokens and set Site Profile Token counts to 0, based on the membership status change
  *   
  *   Created by    :  Mahendra Swarnkar
  * 
  *   Created Date  :  08/21/2019
  *   
  *   Revision Log  :  V1.0 Created - CR-12685 (Created as per the production validation Error/exception).
  *             Coverage - 84%
 **/
global class Sched_UpdateWebProgramAccessOnAccount implements Queueable {
  
    //Variables
    public Set<Id> setAccountIds;
    public Set<Id> setAccountIdsOnInactiveMembership;
    
    //Constructor
    public Sched_UpdateWebProgramAccessOnAccount() {
        setAccountIds = new Set<Id>();
        setAccountIdsOnInactiveMembership = new Set<Id>();
    }
    
    //Queable jobs execute method
    global void execute(QueueableContext context) {
        
        //Check for size
        if(setAccountIds != null && setAccountIds.size() > 0) 
        {
            //Call method that is used to set the Web Program Access on the Institution based on the membership. 
            MembershipTriggerHelper.updateWebProgramAccessOnInstitution(setAccountIds);
        }  
        
        //Check for size
        if(setAccountIdsOnInactiveMembership != null && setAccountIdsOnInactiveMembership.size() > 0) 
        {
            //start a batch job to expire all existing Site Tokens and set Site Profile Token counts to 0
            Batch_TokenReset batchTokenReset = new Batch_TokenReset();
            batchTokenReset.acctIds = setAccountIdsOnInactiveMembership;
            
            //check for condition
            if (!test.isRunningTest()) {
                
                //Schedule the batch
                system.scheduleBatch(batchTokenReset, system.now() + 'batchTokenReset', 5);
            } else if (test.isRunningTest()) {
                
                //Execute the batch
                database.executeBatch(batchTokenReset);
            }
        }
    }
}