/**
 *  Purpose         :   This Job is Used to delete the Component Subscription record for those SBQQ__SegmentStartDate__c is greater than SBQQ__SegmentEndDate__c.
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   04/10/2018
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20180326-12126 
 * 			V_1.1 - Modified By - Subhash Garhwal - 01/05/2021 - CR-20210105-14767
**/
global class DeleteCompSubscriptionEnquueJob implements Database.Batchable<sObject>, Schedulable {
    
    global String debugLog;
    
    //Set to hold the Subscription Ids
    public Set<Id> setCompSubIds = new Set<Id>(); 
    
    public DeleteCompSubscriptionEnquueJob(){}
    
    //Constructor
    public DeleteCompSubscriptionEnquueJob(Set<Id> setCompSubIds) {
    	//reset debug log
        debugLog = '';  
       this.setCompSubIds = setCompSubIds;
    }
	
    
    //Scheduler Execute method 
    global void execute(SchedulableContext ctx) {
        
    	DeleteCompSubscriptionEnquueJob bc = new DeleteCompSubscriptionEnquueJob(setCompSubIds);
        Database.executeBatch(bc);
    }
    
    global  Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator('Select Id, SBQQ__SegmentEndDate__c, SBQQ__SegmentStartDate__c From SBQQ__Subscription__c Where Id IN : setCompSubIds');
    }
    
    //Batch Execute method
    global void execute(Database.BatchableContext BC, list<sObject> sc) {
        
        //List to hold the Component Subscription that is going to be Deleted 
         List<SBQQ__Subscription__c> compSubscriptionToBeDeleted = new List<SBQQ__Subscription__c>();
                  
         //Query the Subscription to get the segment Start and segment End date 
         for(SBQQ__Subscription__c componentSubs : (List<SBQQ__Subscription__c>) sc) {
                                                        
            //Check for the Start and End Date
            if(componentSubs.SBQQ__SegmentStartDate__c > componentSubs.SBQQ__SegmentEndDate__c)
            	compSubscriptionToBeDeleted.add(componentSubs); 
      	}
         
         //Check the Size of Component Subscription
         if(compSubscriptionToBeDeleted.size() > 0) {
             
             //Bypass triggers
             Util.byPassAllTriggers = true;
             
             debugLog += Util.createLog(Database.delete(compSubscriptionToBeDeleted , false));
             
             Util.byPassAllTriggers = false;
         }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'DeleteCompSubscriptionEnquueJob', debugLog, Label.Salesforce_Admin_Email);
    }
    

}