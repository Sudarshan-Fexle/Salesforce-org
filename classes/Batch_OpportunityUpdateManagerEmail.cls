/*
    Purpose         :   batch job to update opportunities with the related User's Manager Email.
                
    Create By       :   Victor Hanson
    
    Created Date    :   08/25/2015
    
    Revision Log    :   V_1.1 Created
						V_1.2 Modified - Dipesh Gupta - For CR-20191025-13465
*/
global class Batch_OpportunityUpdateManagerEmail  implements Database.Batchable<SObject>, Database.Stateful {
    
    
    /** variables **/
    global String debugLogStr;
    public Integer TotalErrors = 0;
    public set<Id> userIds;
    
    /**
     * 
     * @description: constructor
     * 
     **/
    global Batch_OpportunityUpdateManagerEmail(set<Id> userIds) {
        this.userIds = userIds;
        debugLogStr = '';
    }
    
    /**
     * 
     * @description: start Method
     * 
     **/
    global Database.Querylocator start(Database.BatchableContext BC)  {
        
        //return query result
        return Database.getQueryLocator([SELECT Id, Owner.Manager.Email, Owner_Manager_Email__c
                                         FROM Opportunity
                                         WHERE OwnerId IN :userIds]);
    }

    /**
     * 
     * @description: execute method
     * 
     **/
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        
        //List to hold opportunity records to be updated
        List<Opportunity> opportunities = (List<Opportunity>) scope;
        
        //Loop through scope and check if the CPM_Deployment_Status__c not equals to CMA_Status_Formula__c
        for(Opportunity opp : opportunities) {
            
            opp.Owner_Manager_Email__c = opp.Owner.Manager.Email;
        }
        
        //Check list of Deployment record for update
        if(opportunities.size() > 0)  {
            
            //bypass all triggers when making this update
            util.BypassAllTriggers = true;
            
            //update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((opportunities),false));
            
            util.BypassAllTriggers = false;
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }
    }
    
    /**
     * 
     * @description: finish method
     * 
     **/
    global void finish(Database.BatchableContext BC) {
        
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_OpportunityUpdateManagerEmail', debugLogStr,sfAdminUser[0].Email);
        }
        
    }
}