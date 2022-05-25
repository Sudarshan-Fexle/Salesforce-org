/**
  *   Description    :  Scheduler to update the subscription type on void ammended subscription programs to one time.
  *   
  *   Created by    :  Mahendra Swarnkar
  * 
  *   Created Date  :  09/24/2019
  *   
  *   Revision Log  :  V1.0 Created - CR-20190919-13356.
  *             		Coverage - 
 **/
global class Sched_UpdateSubscriptionType implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
	
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //Variable to hold the query
    global Static String query;
    
    //Default Constructor
    global Sched_UpdateSubscriptionType(){}
    
    //parameterized cunstructor
    global Sched_UpdateSubscriptionType(String query) {
        
        Sched_UpdateSubscriptionType.query = query;
        
        //Schedule the sheduler job
       /* dateTime sysTime = dateTime.now().addSeconds(10);
        String chron_exp = '0 0 * * * ?';
        Sched_UpdateSubscriptionType job = new Sched_UpdateSubscriptionType();
		Sched_UpdateSubscriptionType.query = query;
        System.schedule('Sched_UpdateSubscriptionType' + sysTime.getTime(),chron_exp, job);
		*/
    }
    
    //Scheduler Execute Method
    global void execute(SchedulableContext ctx) {
        
        //Execute the apex batch job
        Sched_UpdateSubscriptionType batch = new Sched_UpdateSubscriptionType();
        Sched_UpdateSubscriptionType.query = query;
        Database.executeBatch(batch, 200);
    }
    
    //Batch start method
    global database.querylocator start(database.batchableContext bc) {
        
        //Check for size
        if(String.isBlank(query))
        	query = 'SELECT Id, SBQQ__ProductSubscriptionType__c, SBQQ__SubscriptionType__c FROM SBQQ__Subscription__c Where Status__c = \'Void-Amended\' AND SBQQ__SubscriptionType__c != \'One-time\' AND SBQQ__Contract__r.Status =\'' + CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED +'\'' 
            			+ ' AND RecordTypeId = \''+ CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM + '\'';
        system.debug('@@@@@@ query' + query);
        //Execue the query and returnt the records to execute method in chunks
        return database.getquerylocator(query);
    }
    
    //Batch Execute Method
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        // List to hold the subscriptions to be update
        List<SBQQ__Subscription__c> listToUpdateSubscriptions = new List<SBQQ__Subscription__c>();
        
        //loop over the subscriptions
        for(SBQQ__Subscription__c sub: (List<SBQQ__Subscription__c>)sc){
            
            //Update the subscriptio type
            if(sub.SBQQ__ProductSubscriptionType__c != 'One-time' || sub.SBQQ__SubscriptionType__c != 'One-time'){
               sub.SBQQ__ProductSubscriptionType__c = 'One-time';
               sub.SBQQ__SubscriptionType__c = 'One-time';
                
                //populate the list
                listToUpdateSubscriptions.add(sub);
            }
        }
        
        //Check for size
        if(listToUpdateSubscriptions.size() > 0){
            
            //Bypass all trigger
         	Util.byPassAllTriggers = true;
            
            //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
        	logMessage = Util.createLog(Database.update(listToUpdateSubscriptions,false));
            
            //Enable all triggers
            Util.byPassAllTriggers = false;
        }
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage;
    }
    
    //Batch Fininsh Method
    global void finish(database.batchableContext bc) {
        
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') 
        	//Util.sendBatchStatus(bc.getJobId(), 'Sched_UpdateSubscriptionType', debugLogStr, Label.Salesforce_Admin_Email);
        	Util.sendBatchStatus(bc.getJobId(), 'Sched_UpdateSubscriptionType', debugLogStr, 'mahendra.Swarnkar@fexle.com');
    }
}