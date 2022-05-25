/**
    *	Description	:	The batch is used to delete web services log and send email to sfadmin if any exception would be thrown
    *
    *	Created by	:	Saurabh Kumar
    * 
    * 	Created Date	:	08/17/2017
    * 
    * 	Revision Log	:	V1.0 Created - CR-20170803-11119
    *			:	V1.1 Modified By - Neha Sharma - CR-20211005-15489
    **/
global class Batch_Cleanup  implements Database.Batchable<sObject>, Database.stateful {
    
    //Variable to hold order value
    global Decimal executionOrder;
    
    //Variable to store hold any errors that occur within the execute method
    global String errors = ''; 
    
    //Variable to hold dynamic SOQL query
    String query = '';
    
   /**
    * 	Description	:	Constructor. 
    * 
    * 	@args		:	String 
    * 
    * 	@return		:	
    * 
    * */
    global Batch_Cleanup(String query){
        
        //Assigning the value in local variable
        this.query = query;
    }
    
   /**
    * 	Description	:	Start Method.
    * 
    * 	@args		:	Database.BatchableContext BC
    * 
    * 	@return		:	Database.QueryLocator
    * 
    * */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Query on through query locator
        return Database.getQueryLocator(query);
    }
    
   /**
    * 	Description	:	Execute Method.
    * 
    * 	@args		:	Database.BatchableContext BC, List<sObject> scope
    * 
    * 	@return		:	
    * 
    * */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //String to hold the log message value
        String logMessage = '';
        
        //Iterate through each returned result
        for(Database.DeleteResult deleteResult : Database.delete (scope, false)) {
            
            //Check for success
            if (!deleteResult.isSuccess()) {
                
                //Operation failed, so get all errors
                for(Database.Error err : deleteResult.getErrors()) {
                    
                    //create log message 
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }   
        } 
        
        //Clear the database
        DataBase.emptyRecycleBin(scope);
        
        if(logMessage != '')
            errors += logMessage;
    }
    
   /**
    * 	Description	:	Finish Method.
    * 
    * 	@args		:	Database.BatchableContext BC
    * 
    * 	@return		:	
    * 
    * */
    global void finish(Database.BatchableContext BC){
        
        //Reset the variable
        query = '';
        
        //Checking error string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(String.isNotBlank(query)) {
            Util.sendBatchStatus(BC.getJobId(), 'Batch_Cleanup', errors, Label.SF_ADMIN_EMAIL);
            
            //Reset the variable
            errors = '';
        }
        
        //Modified By - Neha Sharma - CR-20211005-15489
        //Query on the Cleanup custom meta data
        List<Clean_Up__mdt> cleanups = new List<Clean_Up__mdt>();
        
        if(!Util.IsTesting){
            cleanups = [Select Id, Additional_Filter_Clause__c, Object_Name__c, Order__c, Retain_N_days_Records__c, Limit_Of_Records__c From 
                        Clean_Up__mdt Where Order__c >: executionOrder AND Object_Name__c != null AND Active__c = true ORDER BY Order__c ASC LIMIT 1];
        } else {
            cleanups = [Select Id, Additional_Filter_Clause__c, Object_Name__c, Order__c, Retain_N_days_Records__c, Limit_Of_Records__c From 
                        Clean_Up__mdt Where Object_Name__c != null AND Object_Name__c = 'Web_Service_Log__c' AND Active__c = true ORDER BY Order__c ASC LIMIT 1];
        }
        
        //Checking for the list size
        if(cleanups != null && cleanups.size() > 0){
            
            //Getting the query for next ored
            String nextQuery = Scheduler_Batch_Cleanup.getQuery(cleanups[0]);
            
            //Checking for the next query. If not blank then execute the the batch again.
            if(String.isNotBlank(nextQuery)){
                
                //Again initiating the batch for next order 
                Batch_Cleanup cleanup = new Batch_Cleanup(nextQuery);
                
                //Set the Order the execution so that in next execution order would be greater to current
                cleanup.executionOrder = cleanups[0].Order__c;
                if(!Util.IsTesting){
                    //Execute the batch
                    Database.executeBatch(cleanup, 2000);
                }
            }
        }
    }
}