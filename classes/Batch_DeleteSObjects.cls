global class Batch_DeleteSObjects implements Database.Batchable<sObject>, Database.stateful {
    
    /*
    Purpose            :    Batch to delete older Web Service Log records
    
    Created By         :    Ajit Surana
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Ajit Surana - CR-20150122-8591 - 02/23/2015
    */
    
    //Variable to store dynamic soql query
    public String query;
    
    //String to hold object name
    public String sObjType;
    
    //Variable to store hold any errors that occur within the execute method
    global String errors; 

    //Batch Constructor
    global Batch_DeleteSObjects(String objName) {
        sObjType = objName;
        errors = '';
    }

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        if (query == null)
            query = 'Select Id From ' + sObjType + ' WHERE CreatedDate < LAST_N_DAYS:30 ';
        
        return Database.getQueryLocator(query);
    }

    //Execute method
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
        
        if(logMessage != '')
            errors += logMessage;  
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    
        //Checking error string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(errors != '') {
            
            //User Instance
			//Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
			//List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
			//if(sfAdminUser != null && sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_DeleteSObjects', errors, Label.Salesforce_Admin_Email);
        }
    }
}