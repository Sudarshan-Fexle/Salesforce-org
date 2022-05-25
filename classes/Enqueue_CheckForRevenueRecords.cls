/**
*   Description     :   This Class is used to call a method on ABC Revenue trigger. Actually overall goal is to avoid the Future to Future call error we are getting while contracting Opportunity. 
						Because this transaction also runs in asynchronously, and saleforce not allows async to future call.
						So we are creating a enqueue job.
                
*   Created by      :   Dipesh Gupta
*
*   Created Date    :   02/14/2017
*
*   Revision Log    :   V1.0 - Created - Dipesh Gupta - CR-20180918-12607.
*/
public class Enqueue_CheckForRevenueRecords implements Queueable {
	
	//Property
	public List<Id> progSubs = new List<Id>();
	
	//Constructor
	public Enqueue_CheckForRevenueRecords(List<Id> progSubs) {
		
		this.progSubs = progSubs;
	}
	
	
	/**
	     *  @description    :   Execute method that call some another method
     **/
    public void execute(QueueableContext context) {
    	
    	if(progSubs != null && progSubs.size() > 0 ) {
    		
    		//calling this method.
    		//Pass through our Ids to Future Method to check for Revenue records and re-calculate List Price on Revenue records as needed      
            ABCRevenueTriggerHelper.checkForRevenueRecords(progSubs);
    	}
	}
}