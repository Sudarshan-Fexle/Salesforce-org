/**
*   Description     :   This Class is used to check if the Contact id listed as the main contact on the Opportunity. 
                
*   Created by      :   Dipesh Gupta
*
*   Created Date    :   04/03/2019
*
*   Revision Log    :   V1.0 - Created - Dipesh Gupta - CR-20190111-12831
*/
public class Enqueue_CheckContactPrimaryOpportunity implements Queueable {
	
	//Property
	public set<Id> setContactIds = new Set<Id>();
	
	//Constructor
	public Enqueue_CheckContactPrimaryOpportunity(Set<Id> setContactIds) {
		
		this.setContactIds = setContactIds;
	}
	
	
	/**
	     *  @description    :   Execute method that call some another method
     **/
    public void execute(QueueableContext context) {
    	
        //List to hold the Contact that is going to be updated.
        List<Contact> consToBeUpdated = new List<Contact>();
        
    	//Check the size of set. 
        if(setContactIds.size() > 0) {
            
            //Query on the Contact and get the child opportunities where Contact is stamped as Main_Contact.
			for(Contact con : [Select Id, Opportunity_Primary__c, Key_Contact__c, Contact_Status__c, 
                               (Select Id From Opportunities__r Where IsClosed = false Limit 1)  
                               From Contact Where Id IN: setContactIds]) {
            	
                 //Boolean flag for the conditional change.
                 Boolean isOpportunityPrimary = false;
                                   
            	//Checking for the list size. 
                if(con.Contact_Status__c == 'Active' && con.Opportunities__r != null && con.Opportunities__r.size() > 0 ) {
					isOpportunityPrimary = true;
                }  
			
                //Check if con and new check has any diff if yes then update else avoid.
                if(isOpportunityPrimary != con.Opportunity_Primary__c)                    
            		consToBeUpdated.add(new Contact(Id = con.Id, Opportunity_Primary__c = isOpportunityPrimary));
            }
        }
        
        //Check for the list size.
        if(consToBeUpdated.size() > 0) {
            
            //Bypassing trigger true.
            Util.ByPassAllTriggers = true;
            
            //Updating.
            update consToBeUpdated;
            
            //Bypassing trigger false.
            Util.ByPassAllTriggers = false;
        }
	}
}