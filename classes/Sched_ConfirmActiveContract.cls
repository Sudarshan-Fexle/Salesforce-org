global class Sched_ConfirmActiveContract implements Schedulable
{
    /*
    Purpose:    Runs after midnight and kicks off Batch_ConfirmActiveContract.
    
    Create By:          Jeremy Nottingham (SAP)
    
    Last Modified By:   Nathan Banas (SAP) - 1/26/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - (NB) Created code
                        v1.1 - (NB-2011-01-26) Added header, code comments, and reviewed code coverage
                        v1.2 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        
    Code Coverage as of 1/26/2011: 100%
    */
    
    global Integer batchsize = 1;   
    public Id batchprocessid;
    
    global void execute(SchedulableContext ctx)
    {
        //Call Batch with specified batch size
        Batch_ConfirmActiveContract bcac = new Batch_ConfirmActiveContract();
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Setting flag value to true for scheduling next jobs
        bcac.ExecuteNextJob = true;
        
        //Execute Batch
        batchprocessid = Database.executeBatch(bcac, batchsize);
        
        if (batchprocessid != null)
            Util.ScheduleHasRun = true;
    }
}