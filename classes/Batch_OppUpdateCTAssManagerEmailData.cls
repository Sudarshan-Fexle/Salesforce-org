/*
    Purpose         :   batch job to update opportunities with the related CT Assignment's Manager Email.
                
    Create By       :   Dipesh Gupta
    
    Created Date    :   12/11/2019
    
    Revision Log    :   V_1.1 Created
*/
global class Batch_OppUpdateCTAssManagerEmailData implements Database.Batchable<SObject>, Database.Stateful 
{
    global String debugLogStr;
    public Integer TotalErrors = 0;
    public set<Id> userIds;

    global Batch_OppUpdateCTAssManagerEmailData(set<Id> userIds) 
    {
        this.userIds = userIds;
        debugLogStr = '';
    }

    global Database.Querylocator start(Database.BatchableContext BC)  
    {
        return Database.getQueryLocator([SELECT ID, CT_Assignment_s_Manager__c, CT_Assignment__c,
                                         CT_Assignment__r.ManagerId, CT_Assignment__r.Manager.Email
                                         FROM Opportunity
                                         WHERE CT_Assignment__c != null
                                         AND CT_Assignment__c IN : userIds]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) 
    {
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
        List<Opportunity> opportunities = (List<Opportunity>) scope;
        for(Opportunity opp : opportunities) 
        {
            opp.CT_Assignment_s_Manager__c = opp.CT_Assignment__r.Manager.Email;
        }
        //Check list of Deployment record for update
        if(opportunities.size() > 0)  
        {
            util.BypassAllTriggers = true;
            logMessage = Util.createLog(Database.update((opportunities),false));
            util.BypassAllTriggers = false;
            
            //Checking errors log messages string for blank value and append it to 
            //final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //Checking logMessage  string for blank value but if it does not have blank value with it 
        //then emailed it to SFAdmin.
        if(debugLogStr != '') 
        {
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' 
                                      AND IsActive = true AND Profile.Name = 'System Administrator' 
                                      AND Email!= null LIMIT 1];
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_OppUpdateCTAssManagerEmailData', debugLogStr,'abhinav@fexle.com ');
        }
    }
}