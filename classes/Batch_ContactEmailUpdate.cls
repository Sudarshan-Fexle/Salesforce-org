/**
 *  Purpose         :   Batch class is used to update the Contact - This is the one time Batch and need to delete after successful execution.
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   07/18/2018
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20180605-12266
 *                     
**/
global class Batch_ContactEmailUpdate implements Database.Batchable<sObject>{
    	
    
    //Start Method 
    global Database.QueryLocator start(Database.BatchableContext BC){
    
          return Database.getQueryLocator('Select Id, Email, Company_Email__c From Contact Where Email != null');
    
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
        //List to update the contacts
		List<Contact> contactsToBeUpdated = new List<Contact>();

        //Query on the Contact to get the email
        for(Contact con : scope) {
            
             //Logic to populate the contact Email
            if(String.isNotBlank(con.Email)) {
                
                con.Company_Email__c = con.Email;
            }
            
           
            
           contactsToBeUpdated.add(con);
        }
                
        //Check the size of List
        if(contactsToBeUpdated.size() > 0) 
            Database.update(contactsToBeUpdated, false);
  
    }
    
	global void finish(Database.BatchableContext BC){
		
   	}
}